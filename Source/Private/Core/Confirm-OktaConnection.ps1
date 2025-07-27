<#
.SYNOPSIS
  A private helper to ensure the Okta connection is active and the token is valid.
.DESCRIPTION
  This function checks for an active session. If the session is OAuth-based and the access token
  is expired or nearing expiration, it automatically attempts to refresh it using the stored
  refresh token. It returns a valid authorization header for use in API calls.
.OUTPUTS
  [string] - A valid 'Authorization' header string (e.g., "Bearer ...").
#>
function Confirm-OktaConnection {
    [CmdletBinding()]
    param()

    if ($null -eq $script:connectionOkta) {
        throw "Not connected to Okta. Please run Connect-Okta first."
    }

    if ($script:connectionOkta.Tokens -and [DateTime]::UtcNow -ge $script:connectionOkta.Tokens.AccessTokenExpiresAt.AddMinutes(-1)) {
        Write-Verbose "Access token expired or is expiring soon. Attempting to refresh..."
        try {
            $newTokens = Request-OktaRefreshToken -Domain $script:connectionOkta.Domain -ClientID $script:connectionOkta.ClientID -RefreshToken $script:connectionOkta.Tokens.refresh_token -OktaPreview:$script:connectionOkta.OktaPreview
            $newTokens.AccessTokenExpiresAt = [DateTime]::UtcNow.AddSeconds($newTokens.expires_in)
            if (-not $newTokens.refresh_token) {
                $newTokens.refresh_token = $script:connectionOkta.Tokens.refresh_token
            }
            $script:connectionOkta.Tokens = $newTokens
            Write-Verbose "Token refresh successful."
        }
        catch {
            throw "Failed to refresh the access token. You may need to re-authenticate using Connect-Okta. Original error: $_"
        }
    }

    if ($script:connectionOkta.Tokens) {
        return "Bearer $($script:connectionOkta.Tokens.access_token)"
    }
    else {
        return "SSWS $($script:connectionOkta.ApiToken.GetNetworkCredential().password)"
    }
}