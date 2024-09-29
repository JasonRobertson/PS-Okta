function Get-OktaOIDCConfig {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param(
    [parameter(Mandatory)]
    [string]$Domain,
    #[parameter(Mandatory)]
    [string]$ClientID,
    [parameter(Mandatory, ParameterSetName='AuthorizationServer')]
    [string]$AuthorizationServer,
    [switch]$Preview
  )

  $oktaDomain = switch ($Preview){
    true  {-join ('https://',$Domain,'.oktapreview.com')}
    false {-join ('https://',$Domain,'.okta.com')}
  }

  $uri = switch ($PSCmdlet.ParameterSetName) {
    Default             {"$oktaDomain/.well-known/openid-configuration"}
    AuthorizationServer {"$oktaDomain/oauth2/$authorizationServer/.well-known/openid-configuration"}
  }
  try {
    $restMethod = [hashtable]::new()
    $restMethod.Uri = $uri
    if ($clientID) {
      $restMethod.Body = [hashtable]::new()
      $restMethod.Body.client_id = $ClientID
    }
    Invoke-RestMethod @restMethod
  }
  catch {
    $errorDetails = $PSItem.ErrorDetails.Message | ConvertFrom-Json
    $exception = switch ($errorDetails.errorCode) {
      Invalid_Client {
        [Exception]::new("Invalid ClientID: $clientID",$errorDetails.ErrorSummary)
      }
      E0000006 {
        [Exception]::new("Invalid Domain: $domain",$errorDetails.ErrorSummary)
      }
    }
    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
      $exception,
      $errorDetails.errorCode,
      [System.Management.Automation.ErrorCategory]::NotSpecified,
      'Okta'
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
  }
}

