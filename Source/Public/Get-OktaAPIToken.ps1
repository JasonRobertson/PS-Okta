function Get-OktaAPIToken {
  [CmdletBinding()]
  param(
  [string]$Identity
  )
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Endpoint = 'api-tokens'
  

  $response = Invoke-OktaAPI @oktaAPI
  if ($identity) {
    $filterResponse = switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
      True    {$response.where({$_.name -like $Identity -or $_.ID -like $Identity})}
      False   {$response.where({$_.name -eq $Identity -or $_.ID -eq $Identity})}
    }
    if ($filterResponse) {$filterResponse}
    else {
      $message = {}.invoke()
      $message.Add("Failed to retrieve Okta API Token $identity, verify the ID matches one of the examples:")
      $message.Add('ID:   0oa786gznlVSf15sC5d7')
      $message.Add('Name: Local Computer')
  
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
      [Exception]::new(($message | Out-String)),
      'ErrorID',
      [System.Management.Automation.ErrorCategory]::ObjectNotFound,
      'Okta'
      )
      $pscmdlet.ThrowTerminatingError($errorRecord)
    }
  }
  else {
    $response
  }
}