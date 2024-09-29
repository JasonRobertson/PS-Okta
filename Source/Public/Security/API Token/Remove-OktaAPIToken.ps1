function Remove-OktaAPIToken {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Identity
  )
  try {
    $apiTokenID = (Get-OktaAPIToken -Identity $Identity).id
    $oktaAPI              = [hashtable]::new()
    $oktaAPI.Body         = [hashtable]::new()
    $oktaAPI.Method       = 'DELETE'
    $oktaAPI.Endpoint     = "api-tokens/$apiTokenID"
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}