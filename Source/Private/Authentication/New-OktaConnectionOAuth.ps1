# Private helper function for handling the OAuth 2.0 PKCE connection flow.
function New-OktaConnectionOAuth {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [string]$Domain,
        [parameter(Mandatory)]
        [string]$ClientID,
        [parameter(Mandatory)]
        [string]$RedirectUri,
        [parameter(Mandatory)]
        [string[]]$Scopes,
        [parameter(Mandatory)]
        [string]$BaseUri
    )

    Write-Verbose "Connecting using OAuth 2.0 PKCE flow."
    # Step 1: Generate PKCE codes and a state parameter for security
    Write-Verbose "Generating PKCE code verifier and challenge."
    $pkce = New-OktaPKCE -Length 128
    $state = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object { [char]$_ })

    # Step 2: Construct the authorization URL
    Write-Verbose "Constructing authorization URL for Okta."
    $queryParams = @{
        client_id             = $ClientID
        response_type         = 'code'
        scope                 = $Scopes -join ' '
        redirect_uri          = $RedirectUri
        state                 = $state
        code_challenge        = $pkce.CodeChallenge
        code_challenge_method = 'S256'
    }
    $queryString = $queryParams.GetEnumerator() | ForEach-Object { "$($_.Key)=$([System.Net.WebUtility]::UrlEncode($_.Value))" } | Join-String -Separator '&'
    $authUri = "$BaseUri/oauth2/v1/authorize?$queryString"

    # Step 3: Start the browser and the listener concurrently
    Write-Verbose "Starting local listener on $RedirectUri and opening browser to authorization URL."
    Write-Host "Your browser will now open for authentication..."
    Start-Process $authUri
    $callback = Receive-OktaAuthorizationCode -RedirectUri $RedirectUri

    # Step 4: Validate the state and exchange the code for a token
    if ($null -eq $callback) { throw "Authentication cancelled or timed out. The local listener did not receive a callback from Okta." }
    if ($callback.Error) { throw "Authentication failed. Okta returned an error: `"$($callback.ErrorDescription)`" (Error Code: $($callback.Error))" }
    if ($null -eq $callback.Code) { throw "Failed to receive an authorization code from the callback, and no specific error was returned. Please check your Okta application configuration." }
    if ($callback.State -ne $state) { throw "State mismatch detected. This can indicate a Cross-Site Request Forgery (CSRF) attempt. Halting authentication for security." }

    Write-Verbose "Callback received successfully. State parameter validated. Exchanging code for token..."
    $tokenResponse = Request-OktaToken -Domain $Domain -ClientID $ClientID -RedirectUri $RedirectUri -AuthorizationCode $callback.Code -CodeVerifier $pkce.CodeVerifier -OktaPreview:($BaseUri -like '*oktapreview*')
    $tokenResponse | Add-Member -MemberType NoteProperty -Name 'AccessTokenExpiresAt' -Value ([DateTime]::UtcNow.AddSeconds($tokenResponse.expires_in))
    return $tokenResponse
}