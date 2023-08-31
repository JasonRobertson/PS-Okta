function Copy-OktaAppCertificate {
  [CmdletBinding()]
  param(
    [parameter(mandatory)]
    [string]$Identity,
    [string]$Key,
    [string]$TargetApp
  )
  try {
    $appId        = (Get-OktaApp -Identity $identity).id
    $targetAppID  = (Get-OktaApp -Identity $targetApp).id 
    if ($appID -and $targetAppID) {
        $keyID = (Get-OktaAppCertificate -Identity $Identity -Key $key).kid
        if ($keyID) {
          $oktaAPI          = [hashtable]::new()
          $oktaAPI.Method   = 'POST'
          $oktaAPI.EndPoint = "apps/$appId/credentials/keys/$keyID/clone?targetAid=$targetAppID"

          Invoke-OktaAPI @oktaAPI
        }
      }
  }
  catch {
    $PSCmdlet.ThrowTerminatingError($PSItem)
  }
}