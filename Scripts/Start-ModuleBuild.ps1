<#
.SYNOPSIS
  Builds the PS-Okta module from the source files without external dependencies.
.DESCRIPTION
  This script provides a reliable, dependency-free method for building the module.
  It finds all PowerShell source files, combines them into a single .psm1 module file,
  and copies the necessary manifest and asset files to the output directory.
#>
param(
  [version]$Version = '0.0.3'
)

# Script lives under Scripts/; repo root is parent of PSScriptRoot
$repoRoot = Split-Path $PSScriptRoot -Parent
. (Join-Path $PSScriptRoot "Export-ModuleIndex.ps1")

# Define project paths (relative to repo root)
$sourcePath = Join-Path $repoRoot "Source"
$outputPath = Join-Path $repoRoot (Join-Path "Output" "PS-Okta")

# 1. Clean the output directory for a fresh build
Write-Host "Cleaning previous build output..."
if (Test-Path $outputPath) {
    Remove-Item -Path $outputPath -Recurse -Force
}
New-Item -Path $outputPath -ItemType Directory -Force | Out-Null

# 2. Find all source files in the correct order (private functions must be defined before public ones)
Write-Host "Finding source files..."
$privateFiles = Get-ChildItem -Path (Join-Path $sourcePath "Private") -Recurse -Filter "*.ps1"
$publicFiles = Get-ChildItem -Path (Join-Path $sourcePath "Public") -Recurse -Filter "*.ps1"
$allSourceFiles = $privateFiles + $publicFiles

# 3. Assemble the .psm1 module file by concatenating the content of all source files
$outputPsm1 = Join-Path $outputPath "PS-Okta.psm1"
Write-Host "Assembling module file: $outputPsm1"
($allSourceFiles | ForEach-Object { Get-Content -Path $_.FullName -Raw }) -join "`r`n`r`n" | Set-Content -Path $outputPsm1 -Encoding UTF8

# 4. Copy the module manifest and other assets
Write-Host "Copying module manifest and assets..."
Copy-Item -Path (Join-Path $sourcePath "PS-Okta.psd1") -Destination $outputPath
Copy-Item -Path (Join-Path $repoRoot "README.md") -Destination $outputPath
Copy-Item -Path (Join-Path $sourcePath "PS-Okta.nuspec") -Destination $outputPath

# 5. Generate module index for reference (function name, path, synopsis)
Write-Host "Generating module index..."
Export-ModuleIndex -SourcePath $sourcePath -OutputPath $outputPath -RepoRoot $repoRoot

Write-Host -ForegroundColor Green "Build successful. Module created at '$outputPath'."