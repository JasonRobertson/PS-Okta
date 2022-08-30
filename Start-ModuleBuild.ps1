param(
  [version]$Version = '1.0.0'
)
#Requires -Module ModuleBuilder

$params = @{
  SourcePath                  = "$PSScriptRoot\Source\Okta.psd1"

  CopyPaths                   = @("$PSScriptRoot\README.md")
  Version                     = $version
  UnversionedOutputDirectory  = $true
}
Build-Module @params