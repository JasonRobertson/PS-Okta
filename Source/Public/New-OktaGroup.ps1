function New-OktaGroup {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Name,
    [string]$Description,
    [ValidateSet('APP_Group','BUILT_IN','OKTA_GROUP')]
    $Type = 'OKTA_GROUP'
  )
  $body                     = [hashtable]::new()
  $body.type                = $Type
  $body.profile             = [hashtable]::new()
  $body.profile.name        = $Name
  $body.profile.description = $Description

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Body     = $body
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = 'groups'

  Invoke-OktaAPI @oktaAPI
}