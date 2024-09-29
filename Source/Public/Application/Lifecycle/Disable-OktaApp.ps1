function Disable-OktaApp {
  [CmdletBinding()]
  param(
    [parameter(mandatory,position=0)]
    [string]$Identity
  )
  try {
    $appID = (Get-OktaApp -Identity $identity).id
    if ($appID.count -eq 1) {
      $oktaAPI              = [hashtable]::new()
      $oktaAPI.Method       = 'POST'
      $oktaAPI.Endpoint     = "apps/$appID/lifecycle/deactivate"

      Invoke-OktaAPI @oktaAPI
      Get-OktaApp -Identity $identity
    }
    else {
      $message = {
        "$identity returned $($appID.count) results."
        'Please use the ID of the application.'
      }.invoke()
      $oktaError = Write-OktaError $message
      $pscmdlet.ThrowTerminatingError($oktaError)
    }
  }
  catch {
    $oktaError = Write-OktaError $PSITEM.Exception.Message
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
}