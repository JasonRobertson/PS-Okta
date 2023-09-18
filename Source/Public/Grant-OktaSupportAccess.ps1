function Grant-OktaSupportAccess {
  [cmdletbinding()]
  param()
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = 'org/privacy/oktaSupport/grant'
  Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
}