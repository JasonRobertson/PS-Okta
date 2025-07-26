function Request-OktaRefreshToken {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$Domain,

    [Parameter(Mandatory)]
    [string]$ClientID,

    [Parameter(Mandatory)]
    [string]$RefreshToken,

    [switch]$OktaPreview
  )

  $tokenUri = switch ($OktaPreview) {
    true  { "https://$domain.oktapreview.com/oauth2/v1/token" }
    false { "https://$domain.okta.com/oauth2/v1/token" }
  }

  $body = @{
    grant_type    = 'refresh_token'
    client_id     = $ClientID
    refresh_token = $RefreshToken
    scope         = 'openid profile email offline_access' # Re-asserting scopes is good practice
  }

  try {
    Invoke-RestMethod -Method Post -Uri $tokenUri -Body $body -ErrorAction Stop
  }
  catch {
    throw "Failed to refresh Okta token. Error: $($_.Exception.Response.StatusCode) - $($_.Exception.Message)"
  }
}