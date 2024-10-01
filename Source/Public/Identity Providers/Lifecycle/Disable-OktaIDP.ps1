function Disable-OktaIDP {
  param(
    [CmdletBinding()]
    [parameter(Mandatory)]
    [string]$Identity
  )
  try {
    $idpID = (Get-OktaIDP -Identity $Identity).id
    if ($idpID.count -eq 1) {
      $oktaAPI          = [hashtable]
      $oktaAPI.Method   = 'POST'
      $oktaAPI.Endpoint = "idps/$idpID/lifecycle/deactivate"
  
      Invoke-OktaAPI @oktaAPI
    }
    else {
      $oktaError = Write-OktaError "$identity returned $($idpId.count) results. Use the Okta ID instead. Example: 0oa62bfdjnK55Z5x80h7"
      $pscmdlet.ThrowTerminatingError($oktaError)
    }
  }
  catch {
    $oktaError = Write-OktaError $PSItem.Exception.Message
    $PSCmdlet.ThrowTerminatingError($oktaError)
  }
}