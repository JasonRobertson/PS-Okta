function Get-OktaBrand {
  [CmdletBinding()]
  param(
    [string]$Identity,
    [ValidateRange(1,200)]
    [int32]$Limit
  )
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.limit = $Limit
  $oktaAPI.Body.q     = $Identity
  $oktaAPI.Endpoint   = 'brands'
 
  $response = Invoke-OktaAPI @oktaAPI
  if (-not $response) {
    $message = {
      "Failed to retrieve Okta Brand $identity, verify the ID matches one of the examples:"
      'ID:   0oa786gznlVSf15sC5d7'
      'Name: dev-56213942_default'
    }.invoke() | Out-String

    $oktaError = Write-OktaError $message
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
  else {
    return $response | Select-Object -ExpandProperty defaultApp -ExcludeProperty _links, defaultApp
  }
}