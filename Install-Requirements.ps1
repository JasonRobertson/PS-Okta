$modules = 'ModuleBuilder'
foreach ($module in $modules) {
  # Using Install-Module with -Force ensures that the latest version is always installed,
  # updating it if it already exists. This is the simplest way to keep the dependency current.
  Write-Information "Ensuring the latest version of '$($module)' is installed..." -InformationAction Continue
  Install-Module -Name $module -Force -AllowClobber
}