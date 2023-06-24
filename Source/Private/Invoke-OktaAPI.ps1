function Invoke-OktaAPI {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory)]
    [ValidateSet('GET', 'PATCH', 'POST', 'PUT', 'DELETE')]
    [string]$Method,
    [Parameter(Mandatory)]
    [string]$EndPoint,
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
  $restMethod.Uri                   = "$oktaUrl/$endPoint"
  $restMethod.Body                  = $body
  $restMethod.Method                = $method
  $restMethod.UserAgent             = 'PowerShell/PS-Okta'
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

