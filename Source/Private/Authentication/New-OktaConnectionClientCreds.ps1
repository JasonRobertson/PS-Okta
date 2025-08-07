<#
.SYNOPSIS
  A private helper function for handling the OAuth 2.0 Client Credentials connection flow.
.DESCRIPTION
  This function is used internally by Connect-Okta for unattended automation scenarios. It takes an
  application's Client ID and Client Secret, constructs a Basic Authentication header, and exchanges
  them for an access token at the Okta token endpoint.
.OUTPUTS
  [pscustomobject] - An object containing the token response from Okta.
#>
function New-OktaConnectionClientCreds {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$Domain,
        [parameter(Mandatory)]
        [string]$ClientID,
        [parameter(Mandatory)]
        [System.Security.SecureString]$ClientSecret,
        [parameter(Mandatory)]
        [string]$BaseUri,
        [parameter(Mandatory)]
        [string[]]$Scopes
    )

    Write-Verbose "Connecting using OAuth 2.0 Client Credentials flow."

    # Convert the Client ID and Secret to a Base64-encoded string for the Basic Auth header.
    # Use PSCredential to securely handle the SecureString, and clear sensitive variables after use.
    # Scope sensitive variables to try block only
    try {
        $credential = [pscredential]::new($ClientID, $ClientSecret)
        $encodedAuth = [System.Convert]::ToBase64String(
            [System.Text.Encoding]::ASCII.GetBytes(
                "$($credential.UserName):$($credential.GetNetworkCredential().Password)"
            )
        )

        # Store connection info in script scope for use by Connect-Okta and other consumers
        $script:connectionOkta = [ordered]@{ Uri = $BaseUri }
        $body = @{
            'grant_type' = 'client_credentials'
            'scope'      = $Scopes -join ' '
        }
        $headers = @{
            'Authorization' = "Basic $encodedAuth"
            'Accept'        = 'application/json'
        }

        # Pass headers explicitly to the API call for security
        $result = Invoke-OktaAPI -Method POST -Endpoint 'oauth2/v1/token' -Body $body -Headers $headers
    }
    finally {
        # Clear sensitive variables from memory as soon as possible
        if ($encodedAuth)   { Remove-Variable encodedAuth -ErrorAction SilentlyContinue -Force }
        if ($credential)   { Remove-Variable credential -ErrorAction SilentlyContinue -Force }
        # Dispose SecureString if possible (PowerShell 7+)
        if ($ClientSecret -and ($ClientSecret -is [System.IDisposable])) { $ClientSecret.Dispose() }
    }
    return $result
}