function Get-OktaAPIToken {
  [CmdletBinding()]
  param(
  [string]$Identity
  )

  $response = (Invoke-OktaAPI -Endpoint api-tokens).where({$_.id -eq $identity -or $_.name -like "*$Identity*"})
  
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