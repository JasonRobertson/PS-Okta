function Remove-OktaUserType {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    $Identity
  )
  $oktaApi          = [hashtable]::new()
  $oktaApi.Method   = 'DELETE'
  $oktaApi.EndPoint = "meta/types/user/$identity"
  Invoke-OktaAPI @oktaApi
}