param(
  [version]$Version = '0.0.3'
)
#Requires -Module ModuleBuilder

$params = @{
  SourcePath                  = "$PSScriptRoot\Source\PS-Okta.psd1"
  CopyPaths                   = @("$PSScriptRoot\README.md", "$PSScriptRoot\Source\PS-Okta.nuspec")
  Version                     = $version
  UnversionedOutputDirectory  = $true
}
Build-Module @params