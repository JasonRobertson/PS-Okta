function Get-OktaUserGroup {
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [string]$Identity,
    [switch]$UserProfile,
    [int]$Limit = 200,
    [switch]$All
  )
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.All   = $All
  $oktaAPI.Body.Limit = $Limit
  $oktaAPI.Endpoint   = "users/$identity/groups"

  (Invoke-OktaAPI @oktaAPI) | Select-Object id -ExpandProperty profile
}