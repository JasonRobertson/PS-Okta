function Get-OktaGroupMember {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [ValidateRange(1,10000)]
    [int]$Limit = 1000,
    [switch]$All
  )
  $groupID = (Get-OktaGroup -Identity $Identity).id

  $oktaAPI            = [hashtable]::new()
  $oktaAPI.All        = $all
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.limit = $Limit
  $oktaAPI.Endpoint   = "groups/$groupID/users"

  Invoke-OktaAPI @oktaAPI | Select-Object -ExpandProperty Profile -ExcludeProperty credentials, type, Profile
}