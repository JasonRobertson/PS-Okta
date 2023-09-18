function Disable-OktaSupportAccess {
  [cmdletbinding()]
  param()
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = 'org/privacy/oktaSupport/revoke'
  Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
}