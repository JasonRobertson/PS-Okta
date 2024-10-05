function Set-OktaAppUser {
  [CmdletBinding()]
  param(
    [parameter(mandatory,position=0)]
    [string]$Identity,
    [string]$User
  )
  try {
    $app = (Get-OktaApp -Identity $identity)
    if ($app.count -eq 1) {
      if ($app.Status -eq 'INACTIVE') {
        $oktaAPI              = [hashtable]::new()
        $oktaAPI.Method       = 'PATCH'
        $oktaAPI.Endpoint     = "apps/$($app.id)"
  
        Invoke-OktaAPI @oktaAPI
      }
      else {
        $oktaError = Write-OktaError "$($app.Label) application cannot be removed while it is active."
        $pscmdlet.ThrowTerminatingError($oktaError)  
      }
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