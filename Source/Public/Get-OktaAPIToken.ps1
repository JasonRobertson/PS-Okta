function Get-OktaAPIToken {
  [CmdletBinding()]
  param(
  [string]$Identity,
  [ValidateRange(1,200)]
  [int32]$Limit = 20
  )
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.limit = $Limit
  $oktaAPI.Body.q     = $Identity
  $oktaAPI.Endpoint   = 'api-tokens'

  $response = Invoke-OktaAPI @oktaAPI
  
  if (-not $response) {
    $message = {
      "Failed to retrieve Okta API Token $identity, verify the ID matches one of the examples:"
      'ID:   0oa786gznlVSf15sC5d7'
      'Name: Local Computer'
    }.invoke() | Out-String
    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [Exception]::new($message),
    'ErrorID',
    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
    'Okta'
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
  }
  return $response
}