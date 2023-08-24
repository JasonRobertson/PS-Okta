$modules = 'ModuleBuilder'
foreach ($module in $modules) {
  try {
    Get-InstalledModule -Name $module -ErrorAction Stop
  }
  catch {
    Write-Information "Installing $module" -InformationAction Continue
    Install-Module -Name $module -Force
  }
}