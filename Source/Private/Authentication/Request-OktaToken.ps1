<#
.SYNOPSIS
  A private helper function to exchange an authorization code for access and refresh tokens.
.DESCRIPTION
  This function is used internally by Connect-Okta as part of the OAuth 2.0 Authorization Code with PKCE flow.
  It makes a POST request to the Okta token endpoint, providing the necessary credentials and the authorization code
  to receive the final tokens.
.INPUTS
  [string]$Domain
  [string]$ClientID
  [string]$RedirectUri
  [string]$AuthorizationCode
  [string]$CodeVerifier
  [switch]$OktaPreview
.OUTPUTS
  [pscustomobject] - The token response object from Okta, containing access_token, refresh_token, etc.
#>
function Request-OktaToken {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [string]$Domain,

        [Parameter(Mandatory)]
        [string]$ClientID,

        [Parameter(Mandatory)]
        [string]$RedirectUri,

        [Parameter(Mandatory)]
        [string]$AuthorizationCode,

        [Parameter(Mandatory)]
        [string]$CodeVerifier,

        [switch]$OktaPreview
    )

    $uri = switch ($OktaPreview){
        $true  {-join ('https://',$Domain,'.oktapreview.com')}
        $false {-join ('https://',$Domain,'.okta.com')}
    }
    $tokenEndpoint = "$uri/oauth2/v1/token"

    $body = @{
        grant_type    = 'authorization_code'
        client_id     = $ClientID
        redirect_uri  = $RedirectUri
        code          = $AuthorizationCode
        code_verifier = $CodeVerifier
    }

    try {
        Write-Verbose "Requesting tokens from endpoint: $tokenEndpoint"
        return Invoke-RestMethod -Method POST -Uri $tokenEndpoint -Body $body -ContentType 'application/x-www-form-urlencoded' -ErrorAction Stop
    }
    catch {
        throw "Failed to exchange authorization code for tokens. The API returned an error: $_"
    }
}