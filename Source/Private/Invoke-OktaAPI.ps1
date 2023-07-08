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
  try {
    switch ($All) {
      true  {Invoke-RestMethod @restMethod -FollowRelLink}
      false {Invoke-RestMethod @restMethod}
    }
  }
  catch {
    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
      [Exception]::new($($PSItem.ErrorDetails.Message | ConvertFrom-Json).errorSummary),
      'ErrorID',
      [System.Management.Automation.ErrorCategory]::NotSpecified,
      'Okta'
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
  }
}

