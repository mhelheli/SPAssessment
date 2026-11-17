#Requires -Version 7.0
Set-StrictMode -Version Latest

function Get-SPSiteAssessment {
    <#
    .SYNOPSIS
        Pre-migration assessment of one SharePoint Online site.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$ClientId
    )

    $result = [ordered]@{
        Url             = $Url
        Exists          = $false
        Title           = $null
        Template        = $null
        LibraryCount    = $null
        TotalFiles      = $null
        LibraryDetails  = $null
        Status          = 'Unknown'
        Error           = $null
    }

    try {
        $conn = Connect-PnPOnline -Url $Url -ClientId $ClientId -Interactive -ReturnConnection -ErrorAction Stop
        $web  = Get-PnPWeb -Connection $conn -Includes WebTemplate, Configuration, Title -ErrorAction Stop
        $result.Exists   = $true
        $result.Title    = $web.Title
        $result.Template = '{0}#{1}' -f $web.WebTemplate, $web.Configuration

        # BaseTemplate 101 = document library; ItemCount includes folders.
        $libs = Get-PnPList -Connection $conn -ErrorAction Stop |
            Where-Object { $_.BaseTemplate -eq 101 -and -not $_.Hidden }
        $result.LibraryCount   = @($libs).Count
        $result.TotalFiles     = ($libs | Measure-Object -Property ItemCount -Sum).Sum
        $result.LibraryDetails = (@($libs) | ForEach-Object { '{0} ({1})' -f $_.Title, $_.ItemCount }) -join '; '
        $result.Status = 'OK'
    }
    catch {
        $msg = $_.Exception.Message
        $result.Error = $msg
        $result.Status = if ($msg -match '404|does not exist|n''existe pas|Not Found') { 'NotFound' } else { 'Error' }
    }

    [pscustomobject]$result
}

function Export-SPAssessmentHtml {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][object[]]$Report,
        [Parameter(Mandatory)][string]$Path
    )

    $enc = { param($v) [System.Net.WebUtility]::HtmlEncode([string]$v) }
    $cols = 'Url', 'Exists', 'Title', 'Template', 'LibraryCount', 'TotalFiles', 'LibraryDetails', 'Status', 'Error'

    $total = @($Report).Count
    $ok    = @($Report | Where-Object Status -eq 'OK').Count
    $nf    = @($Report | Where-Object Status -eq 'NotFound').Count
    $err   = @($Report | Where-Object Status -eq 'Error').Count

    $head = ($cols | ForEach-Object { "<th>$_</th>" }) -join ''
    $rows = foreach ($r in $Report) {
        $cells = ($cols | ForEach-Object { "<td>$(& $enc $r.$_)</td>" }) -join ''
        "<tr class=`"$(& $enc $r.Status)`">$cells</tr>"
    }

    $html = @"
<!DOCTYPE html>
<html lang=`"en`"><head><meta charset=`"utf-8`"><title>SharePoint Assessment</title>
<style>
body{font-family:Segoe UI,Arial,sans-serif;margin:24px}
table{border-collapse:collapse;width:100%;font-size:13px}
th,td{border:1px solid #ccc;padding:6px 8px;text-align:left;vertical-align:top}
th{background:#0f6cbd;color:#fff}
tr.OK td:nth-child(8){color:#107c10;font-weight:600}
tr.NotFound{background:#fff4ce}
tr.Error{background:#fde7e9}
</style></head><body>
<h1>SharePoint pre-migration assessment</h1>
<p>Generated $(Get-Date -Format 'yyyy-MM-dd HH:mm') - Sites: $total | OK: $ok | NotFound: $nf | Error: $err</p>
<table><thead><tr>$head</tr></thead><tbody>
$($rows -join "`n")
</tbody></table></body></html>
"@
    Set-Content -Path $Path -Value $html -Encoding UTF8
}

function Invoke-SPAssessment {
    <#
    .SYNOPSIS
        Assess a list of SharePoint sites (CSV with a 'Url' column) and export a CSV report.
    .EXAMPLE
        Invoke-SPAssessment -InputCsv .\sites.csv -ClientId <guid> -OutputCsv .\report.csv
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$InputCsv,
        [Parameter(Mandatory)][string]$ClientId,
        [string]$OutputCsv = (Join-Path (Get-Location) ("SPAssessment_{0:yyyyMMdd_HHmmss}.csv" -f (Get-Date))),
        [string]$OutputHtml
    )

    if (-not (Get-Module -ListAvailable -Name PnP.PowerShell)) {
        throw "PnP.PowerShell is required. Install it: Install-Module PnP.PowerShell -Scope CurrentUser"
    }
    Import-Module PnP.PowerShell -ErrorAction Stop

    $sites = Import-Csv -Path $InputCsv
    if (-not ($sites | Get-Member -Name Url)) { throw "The CSV must contain a 'Url' column." }

    $i = 0
    $report = foreach ($s in $sites) {
        $i++
        Write-Progress -Activity 'SharePoint assessment' -Status $s.Url -PercentComplete (100 * $i / @($sites).Count)
        Get-SPSiteAssessment -Url $s.Url.Trim() -ClientId $ClientId
    }

    $report | Export-Csv -Path $OutputCsv -NoTypeInformation -Encoding UTF8
    Write-Host "Report written to $OutputCsv" -ForegroundColor Green
    if ($OutputHtml) {
        Export-SPAssessmentHtml -Report $report -Path $OutputHtml
        Write-Host "HTML report written to $OutputHtml" -ForegroundColor Green
    }
    $report
}

Export-ModuleMember -Function Get-SPSiteAssessment, Invoke-SPAssessment, Export-SPAssessmentHtml
