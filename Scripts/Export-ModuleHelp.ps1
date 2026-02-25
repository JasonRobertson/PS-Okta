<#
.SYNOPSIS
  Generates HelpInfo XML and MAML help for PS-Okta (for Update-Help / PSGallery).
.DESCRIPTION
  Uses platyPS to generate Markdown from the built module, then MAML and HelpInfo XML.
  Run after Start-ModuleBuild.ps1. Requires the platyPS module (Install-Module platyPS -Scope CurrentUser).
  Output is written to docs/Help (HelpInfo XML and en-US MAML).
.PARAMETER ModulePath
  Path to the built module folder (containing PS-Okta.psm1). Defaults to repo Output\PS-Okta.
.PARAMETER OutputPath
  Path to write HelpInfo and MAML. Defaults to repo docs\Help.
#>
[CmdletBinding()]
param(
  [string]$ModulePath = (Join-Path (Split-Path $PSScriptRoot -Parent) (Join-Path "Output" "PS-Okta")),
  [string]$OutputPath = (Join-Path (Split-Path $PSScriptRoot -Parent) (Join-Path "docs" "Help"))
)

if (-not (Get-Module -ListAvailable -Name platyPS)) {
  Write-Error "platyPS is required. Run: Install-Module platyPS -Scope CurrentUser"
  return
}
Import-Module platyPS -ErrorAction Stop

if (-not (Test-Path $ModulePath)) {
  Write-Error "Module path not found: $ModulePath. Run Scripts\Start-ModuleBuild.ps1 first."
  return
}
# Loaded module is the built .psm1 from Output. Run Start-ModuleBuild.ps1 first so fixes in Source are included.

$mdPath = Join-Path $OutputPath "Markdown"
$enUsPath = Join-Path $OutputPath "en-US"
New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
New-Item -ItemType Directory -Path $mdPath -Force | Out-Null
New-Item -ItemType Directory -Path $enUsPath -Force | Out-Null

# Load the built module to get commands
$savedModulePath = $env:PSModulePath
try {
  $env:PSModulePath = (Join-Path $ModulePath "..") + [System.IO.Path]::PathSeparator + $env:PSModulePath
  Import-Module $ModulePath -Force -ErrorAction Stop
  Get-Module PS-Okta | Out-Null
} finally {
  $env:PSModulePath = $savedModulePath
}

# Generate Markdown (creates/updates MD per command)
# Suppress Get-Help introspection errors (validValues, Add) from dynamic parameters when platyPS inspects the module
Write-Host "Generating Markdown help..."
& {
  $ErrorActionPreference = 'SilentlyContinue'
  $WarningPreference = 'SilentlyContinue'
  $InformationPreference = 'SilentlyContinue'
  New-MarkdownHelp -Module PS-Okta -OutputFolder $mdPath -Force *>&1 | Out-Null
}

# Generate MAML from Markdown
Write-Host "Generating MAML help..."
New-ExternalHelp -Path $mdPath -OutputPath $enUsPath -Force

# Generate HelpInfo XML when supported (platyPS; some versions lack New-ExternalHelpInfo)
Write-Host "Generating HelpInfo XML..."
if (Get-Command New-ExternalHelpInfo -ErrorAction SilentlyContinue) {
  try {
    New-ExternalHelpInfo -Path $enUsPath -OutputPath $OutputPath
  } catch {
    Write-Warning "New-ExternalHelpInfo failed: $($_.Exception.Message). You can create HelpInfo XML manually; see docs/Help/README.md."
  }
} else {
  Write-Warning "New-ExternalHelpInfo is not available in this platyPS version. Create HelpInfo XML manually if needed; see docs/Help/README.md."
}

Write-Host -ForegroundColor Green "Help output written to: $OutputPath"
Write-Host "  HelpInfo: $OutputPath\*.HelpInfo.xml"
Write-Host "  MAML:     $enUsPath\*.xml"
