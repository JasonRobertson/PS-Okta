function Unlock-OktaUser {
  [CmdletBinding()]
  param(
    [parameter(mandatory)]
    [string]$Identity
  )
  try {
    $userId = (Get-OktaUser -Identity $Identity).id
    
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = "users/$userId/lifecycle/unlock"

    Invoke-OktaAPI @oktaAPI
  }
  catch {
    $message = Write-OktaError $PSITEM.Exception.Message
    $pscmdlet.ThrowTerminatingError($message)
  }
}