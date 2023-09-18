function Enable-OktaDashboardFooter {
  [cmdletbinding()]
  param()
  try {
    $oktaApi = [hashtable]::new()
    $oktaApi.Method = 'POST'
    $oktaApi.EndPoint = 'org/preferences/showEndUserFooter'
    Invoke-OktaAPI @oktaApi  | Select-Object -ExcludeProperty _links
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}