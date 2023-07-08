function Get-OktaUserGroups {
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [string]$Identity,
    [switch]$UserProfile,
    [int]$Limit = 200,
    [switch]$All
  )
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.Limit = $Limit
  $oktaAPI.Body.All   = $All
  $oktaAPI.Endpoint   = "$oktaUrl/users/$identity/groups"

  Invoke-OktaAPI @oktaAPI
}