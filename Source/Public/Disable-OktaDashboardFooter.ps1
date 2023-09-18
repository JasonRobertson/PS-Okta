function Disable-OktaDashboardFooter {
  [cmdletbinding()]
  param()
  try {
    $oktaApi = [hashtable]::new()
    $oktaApi.Method = 'POST'
    $oktaApi.EndPoint = 'org/preferences/hideEndUserFooter'
    Invoke-OktaAPI @oktaApi  | Select-Object -ExcludeProperty _links | Select-Object -ExcludeProperty _links
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}