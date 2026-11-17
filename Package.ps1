#Requires -Version 7.0
# Builds a shareable zip containing the agent and the module.
param([string]$OutputPath = (Join-Path $PSScriptRoot 'SPAssessment-Agent.zip'))

$items = @('.github/agents', 'SPAssessment') | ForEach-Object { Join-Path $PSScriptRoot $_ }
if (Test-Path $OutputPath) { Remove-Item $OutputPath }
Compress-Archive -Path $items -DestinationPath $OutputPath
Write-Host "Package created: $OutputPath" -ForegroundColor Green
