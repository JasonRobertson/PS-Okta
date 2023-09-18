function Push-OktaSupportAccess {
  [cmdletbinding()]
  param()
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = 'org/privacy/oktaSupport/extend'
  Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
}