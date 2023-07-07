function Set-OktaUserType {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param(
    #The unique key for the User Type
    [parameter(Mandatory,ParameterSetName='Identity')]
    [string]$Identity,
    #The updated human-readable display name for the User Type
    [string]$DisplayName,
    #The updated human-readable description of the User Type
    [string]$Description
  )
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = "meta/types/user/$identity"

  $oktaAPI.Body     = [hashtable]::new()
  if ($DisplayName)  {$oktaAPI.Body.displayName = $DisplayName}
  if ($Description ) {$oktaAPI.Body.description = $Description}
  Invoke-OktaAPI @oktaAPI
}