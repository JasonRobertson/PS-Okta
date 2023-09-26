function Get-OktaAPIToken {
  [CmdletBinding()]
  param(
  [string]$Identity
  )  
  $response = Invoke-OktaAPI -Endpoint api-tokens
  if ($identity) {
    $response = switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
      True    {$response.where({$_.name -like $Identity -or $_.ID -like $Identity})}
      False   {$response.where({$_.name -eq $Identity -or $_.ID -eq $Identity})}
    }
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
  }
  return $response
}