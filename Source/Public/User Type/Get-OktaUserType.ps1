function Get-OktaUserType {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param(
    #The unique key for the User Type
    [parameter(ParameterSetName='Identity')]
    $Identity
  )
  $oktaApi          = [hashtable]::new()
  $oktaApi.Method   = 'GET'
  $oktaApi.EndPoint = switch ($PSCmdlet.ParameterSetName) {
    Default  {'meta/types/user'}
    Identity {"meta/types/user/$identity"}
  }
  Invoke-OktaAPI @oktaApi
}