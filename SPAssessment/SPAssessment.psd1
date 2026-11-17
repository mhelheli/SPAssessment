@{
    RootModule            = 'SPAssessment.psm1'
    ModuleVersion         = '0.1.0'
    GUID                  = 'b6f1c1de-4a0e-4f6a-9d58-3c2f7a1e9a10'
    Author                = 'Avanade'
    Description           = 'Basic SharePoint Online pre-migration assessment (existence, template, libraries, file count).'
    PowerShellVersion     = '7.0'
    FunctionsToExport     = @('Get-SPSiteAssessment', 'Invoke-SPAssessment', 'Export-SPAssessmentHtml')
    CmdletsToExport       = @()
    VariablesToExport     = @()
    AliasesToExport       = @()
}
