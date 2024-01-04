function Get-OktaAppUser {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [string]$User,
    [switch]$All
  )
  try {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Body     = [hashtable]::new()
    $oktaAPI.Body.q   = $user
    $oktaAPI.All      = $all
    $oktaAPI.Endpoint = "apps/$identity/users"
    Invoke-OktaAPI @oktaAPI | Select-Object -ExpandProperty Credentials -ExcludeProperty Credentials | Select-Object -ExpandProperty Profile -ExcludeProperty Profile
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}