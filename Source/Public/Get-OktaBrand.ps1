function Get-OktaBrand {
  [CmdletBinding()]
  param(
    [string]$Identity
  )
  $response = Invoke-OktaAPI -Endpoint 'brands'
  if ($identity) {
    $response = switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
      True    {$response.where({$_.name -like $Identity -or $_.ID -like $Identity})}
      False   {$response.where({$_.name -eq   $Identity -or $_.ID -eq   $Identity})}
    }
    if (-not $response) {
      $message = {
        "Failed to retrieve Okta Brand $identity, verify the ID matches one of the examples:"
        'ID:   0oa786gznlVSf15sC5d7'
        'Name: dev-56213942_default'
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
  return $response | Select-Object -ExpandProperty defaultApp -ExcludeProperty _links, defaultApp
}