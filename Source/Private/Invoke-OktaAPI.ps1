function Invoke-OktaAPI {
  [CmdletBinding()]
  Param(
    [ValidateSet('GET', 'PATCH', 'POST', 'PUT', 'DELETE')]
    [string]$Method='GET',
    [Parameter(Mandatory)]
    [string]$Endpoint,
    $Body,
    [switch]$All
  )
  #Verify the connection has been established
  $oktaUrl = Test-OktaConnection

  $body = switch ($Method -match '^GET|DELETE$' ) {
    True  {$body}
    False {$body | ConvertTo-Json -Depth 100}
  }

  $restMethod                       = [hashtable]::new()
  $restMethod.Uri                   = "$oktaUrl/$Endpoint"
  $restMethod.Body                  = $body
  $restMethod.Method                = $method
  $restMethod.ContentType           = 'application/json'
  $restMethod.Headers               = [hashtable]::new()
  $restMethod.Headers.Accept        = 'application/json'
  $restMethod.Headers.Authorization = Convert-OktaAPIToken
  $restMethod.FollowRelLink         = $all

  try {
    Invoke-RestMethod @restMethod
  }
  catch {
    $message = ($PSItem.ErrorDetails.Message | ConvertFrom-Json).errorSummary.TrimStart('Not found: ')
    #Write-OktaError -Message $message
    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
      [Exception]::new($message),
      'ErrorID',
      [System.Management.Automation.ErrorCategory]::NotSpecified,
      'Okta'
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
  }
}