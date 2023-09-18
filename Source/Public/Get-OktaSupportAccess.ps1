function Get-OktaSupportAccess {
  [cmdletbinding()]
  param()
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.EndPoint = 'org/privacy/oktaSupport'
  Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
}