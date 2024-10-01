function Get-OktaIDP {
  [CmdletBinding()]
  param(
    [string]$Identity,
    [ValidateSet( 'Amazon','Apple','Discord','Facebook',
                  'GitHub','GitLab','Google','LinkedIn',
                  'LoginGov','LoginGov Sandbox','Microsoft',
                  'OIDC','Paypal','Paypal Sandbox','Salesforce',
                  'SAML2','Spotify','X509','Xero','Yahoo','Yahoo Japan')]
    [string]$Type,
    [validateRange(1,200)]
    [int]$Limit = 200,
    [switch]$All
  )

  $body             = [hashtable]::new()
  $body.type        = $type
  $body.limit       = $limit
  $body.q           = $identity

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.All      = $all
  $oktaAPI.Body     = $body
  $oktaAPI.Method   = 'GET'
  $oktaAPI.Endpoint = "idps"

  $oktaResults = Invoke-OktaAPI @oktaAPI
  if ($oktaResults) {$oktaResults}
  else {
    $oktaError = Write-OktaError "No results found for $identity. Check spelling or use the Okta ID. Example: 0oa62bfdjnK55Z5x80h7"
    $PSCmdlet.ThrowTerminatingError($oktaError)
  }
}