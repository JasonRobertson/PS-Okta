$modules = 'MoudleBuilder'
foreach ($module in $modules) {
  try {
    Get-InstalledModule -Name $module -ErrorAction Stop
  }
  catch {
    Write-Host "Installing $module"
    Install-Module -Name $module -Force
  }
}