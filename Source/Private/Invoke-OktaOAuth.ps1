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

  #Proof Key for Code Exchange (PKCE)
  $private:PKCE = New-OktaPKCE

  # Random generation that is URL safe
  $state = -join (((48..57) * 4) + ((65..90) * 4) + ((97..122) * 4) | Get-Random -Count 28 | ForEach-Object { [char]$_ })

  $webRequest                             = [hashtable]::new()
  $webRequest.URI                         = "https://$domain/oauth2/v1/authorize"
  $webRequest.Method                      = 'GET'
  $webRequest.Body                        = [hashtable]::new()
  $webRequest.Body.client_id              = $clientID
  $webRequest.Body.code_challenge         = $private:PKCE.CodeChallenge
  $webRequest.Body.code_challenge_method  = 'S256'
  $webRequest.Body.scope                  = $Scopes
  $webRequest.Body.redirect_uri           = $RedirectUri
  $webRequest.Body.state                  = $state #Investigate

  $response = Invoke-WebRequest @webRequest

  

}