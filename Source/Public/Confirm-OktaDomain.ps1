function Confirm-OktaDomain {
  [cmdletbinding()]
  param(
    [parameter(Mandatory)]
    [string]$Identity
  )
  try {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = "domains/$Identity/verify"
    Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}