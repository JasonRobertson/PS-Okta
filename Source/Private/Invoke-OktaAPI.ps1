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

  $webRequest                       = [hashtable]::new()
  $webRequest.Uri                   = "$oktaUrl/$endPoint"
  $webRequest.Body                  = $body
  $webRequest.Method                = $method
  $webRequest.UserAgent             = 'PowerShell/PS-Okta'
  $webRequest.ContentType           = 'application/json'
  $webRequest.Headers               = [hashtable]::new()
  $webRequest.Headers.Accept        = 'application/json'
  $webRequest.Headers.Authorization = Convert-OktaAPIToken
  try {
    switch ($All) {
      true  {Invoke-RestMethod @webRequest -FollowRelLink}
      false {Invoke-RestMethod @webRequest}
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

