function Expand-OktaSupportAccess {
  [cmdletbinding()]
  param()
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = 'org/privacy/oktaSupport/extend'
  try {
    Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}