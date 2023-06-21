function Invoke-OktaOAuth {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Domain,
    [parameter(Mandatory)]
    $ClientID,
    [string]$RedirectUri = 'http://localhost:8080/authorization-code/callback',
    [string[]]$Scopes
  )


  $webRequest         = [hashtable]::new()
  $webRequest.URI     = "https://$domain/oauth2/v1/authorize"
  $webRequest.Method  = 'POST'
  $webRequest.Body                = [hashtable]::new()
  $webRequest.Body.client_id      = $clientID
  $webRequest.Body.response_type  = 'token'
  $webRequest.Body.response_mode  = 'fragment'
  $webRequest.Body.scope          = $Scopes
  $webRequest.Body.redirect_uri   = $RedirectUri
  $webRequest.Body.nonce          = 'UBGW' #Investigate
  $webRequest.Body.state          = '1234' #Investigate

  Invoke-WebRequest @webRequest

}