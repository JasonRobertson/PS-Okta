function Remove-OktaBrand {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Identity
  )
  try {
    $brandID = (Get-OktaBrand -Identity $Identity).id
    $oktaAPI              = [hashtable]::new()
    $oktaAPI.Body         = [hashtable]::new()
    $oktaAPI.Method       = 'DELETE'
    $oktaAPI.Endpoint     = "brands/$brandID"
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}