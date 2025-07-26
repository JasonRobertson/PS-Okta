<#
  .Synopsis
    Connect-Okta is used to establish the connection to the Organization Okta.
  .DESCRIPTION
    Connect-Okta is used to establish the connection to the Organization Okta. Requires an API Token generated within Okta Admin Portal.
  .EXAMPLE
    PS C:\> Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg'
    
    Your browser will now open for authentication...
    Connected successfully to 'My Company' as 'admin@example.com'
    
    CompanyName : My Company
    Domain      : my-org
    URI         : https://my-org.okta.com/api/v1
    User        : admin@example.com
    UserID      : 00u123456789abcdefg
    
    Connects to Okta using the recommended OAuth 2.0 interactive flow.
  .EXAMPLE
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    PS C:\> $cred = Get-Credential -Message 'Enter your Okta API Token'
    PS C:\> Connect-Okta -Domain my-org -ApiToken $cred

    Connects to Okta using a legacy API Token, securely prompting for the token. This is useful for automation or admin tasks.
  .INPUTS
    None
  .OUTPUTS
    A connection object is stored in the session. Status information is written to the host.
  .NOTES
    No other cmdlets will work without having run Connect-Okta first.
  .COMPONENT
  .ROLE
    To verify Okta Org and API Token are valid.
  .FUNCTIONALITY
    Sends a query to Okta to verify the Okta Org and API Token provider are valid and caches Okta Url, API Token, and
    within the powershell session to run other commands in the Okta module.
#>
function Connect-Okta {
  [CmdletBinding(DefaultParameterSetName='OAuth')]
  param(
    [parameter(Mandatory)]
    [string]$Domain,

    # --- API Token Parameter Set ---
    [parameter(Mandatory, ParameterSetName='ApiToken')]
    [pscredential]$ApiToken,

    # --- OAuth PKCE Parameter Set ---
    [parameter(Mandatory, ParameterSetName='OAuth')]
    [string]$ClientID,
    [parameter(ParameterSetName='OAuth')]
    [string]$RedirectUri = 'http://localhost:8080/',
    [parameter(ParameterSetName='OAuth')]
    [string[]]$Scopes = @('openid', 'profile', 'email', 'offline_access'),

    # --- Common Parameters ---
    [switch]$Preview
  )
  process {
    try {
      # Initialize a hashtable to gather all connection properties
      $requestor     = $null
      $tokenResponse = $null

      Write-Verbose "Determining Okta base URI..."
      $uri = switch ($Preview){
        true  {-join ('https://',$Domain,'.oktapreview.com')}
        false {-join ('https://',$Domain,'.okta.com')}
      }
      Write-Verbose "Using URI: $uri"

      if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
        Write-Verbose "Connecting using OAuth 2.0 PKCE flow."
        # Step 1: Generate PKCE codes and a state parameter for security
        Write-Verbose "Generating PKCE code verifier and challenge."
        $pkce = New-OktaPKCE -Length 128
        $state = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | ForEach-Object { [char]$_ })

        # Step 2: Construct the authorization URL
        Write-Verbose "Constructing authorization URL for Okta."
        $authUri = "$uri/oauth2/v1/authorize?" + @(
          "client_id=$([uri]::EscapeDataString($ClientID))",
          "response_type=code",
          "scope=$([uri]::EscapeDataString($Scopes -join ' '))",
          "redirect_uri=$([uri]::EscapeDataString($RedirectUri))",
          "state=$([uri]::EscapeDataString($state))",
          "code_challenge=$([uri]::EscapeDataString($pkce.CodeChallenge))",
          "code_challenge_method=S256"
        ) -join '&'

        # Step 3: Start the browser and the listener concurrently
        Write-Verbose "Starting local listener on $RedirectUri and opening browser to authorization URL."
        Write-Host "Your browser will now open for authentication..."
        Start-Process $authUri
        $callback = Receive-OktaAuthorizationCode -RedirectUri $RedirectUri

        # Step 4: Validate the state and exchange the code for a token
        if ($null -eq $callback.Code) { Write-Error "Failed to receive authorization code from callback."; return }
        if ($callback.State -ne $state) { Write-Error "State mismatch. Possible security risk. Halting authentication."; return }

        Write-Verbose "Callback received successfully. State parameter validated."
        Write-Verbose "Authorization code received. Exchanging for access token..."
        $tokenResponse = Request-OktaToken -Domain $Domain -ClientID $ClientID -RedirectUri $RedirectUri -AuthorizationCode $callback.Code -CodeVerifier $pkce.CodeVerifier -OktaPreview:$Preview

        # Calculate and add the token's expiration timestamp
        $tokenResponse.AccessTokenExpiresAt = [DateTime]::UtcNow.AddSeconds($tokenResponse.expires_in)

        Write-Verbose "Access token and refresh token received. Creating connection object."
      }
      else { # ApiToken Parameter Set
        Write-Verbose "Connecting using legacy API Token."
        $headers = @{
          Accept        = 'application/json'
          Authorization = "SSWS $($apiToken.GetNetworkCredential().password)"
        }
        # Test connection and fetch user data in one call to reduce latency
        Write-Verbose "Testing API Token and fetching user details from /api/v1/users/me..."
        $requestor = Invoke-RestMethod -Method GET -Uri "$uri/api/v1/users/me" -Headers $headers -ErrorAction Stop

        Write-Verbose "API Token is valid. Creating connection object."
      }

      # Common connection success logic: Fetch user and org details
      Write-Verbose "Fetching user and organization details to populate connection object."
      $authHeader = if ($tokenResponse) { "Bearer $($tokenResponse.access_token)" } else { "SSWS $($apiToken.GetNetworkCredential().password)" }
      $commonHeaders = @{ Accept = 'application/json'; Authorization = $authHeader }

      if ($null -eq $requestor) {
        Write-Verbose "Fetching user details from /api/v1/users/me."
        $requestor = Invoke-RestMethod -Method GET -Uri "$uri/api/v1/users/me" -Headers $commonHeaders
      }

      Write-Verbose "Fetching organization details from /api/v1/org."
      $organization = Invoke-RestMethod -Method GET -Uri "$uri/api/v1/org" -Headers $commonHeaders

      # Create the final, complete connection object with a defined order
      Write-Verbose "Updating connection object with user: $($requestor.profile.login) and company: $($organization.CompanyName)."
      $connectionObject = [ordered]@{
          CompanyName = $organization.CompanyName
          Domain      = $Domain
          URI         = "$uri/api/v1"
          OktaPreview = $Preview
          User        = $requestor.profile.login
          UserID      = $requestor.Id
      }

      # Add authentication-specific properties which are not for display
      if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
          $connectionObject.Tokens   = $tokenResponse
          $connectionObject.ClientID = $ClientID
      } else {
          $connectionObject.ApiToken = $apiToken
      }
      
      $script:connectionOkta = [pscustomobject]$connectionObject

      $status = "Connected successfully to '$($organization.companyName)' as '$($requestor.profile.login)'"
      Write-Host -ForegroundColor Green $status

      # --- Custom Output Formatting ---
      $displayObject = [ordered]@{
          CompanyName = $script:connectionOkta.CompanyName
          Domain      = $script:connectionOkta.Domain
          URI         = $script:connectionOkta.URI
          User        = $script:connectionOkta.User
          UserID      = $script:connectionOkta.UserID
      }
      if ($script:connectionOkta.OktaPreview) {
          $displayObject.Add('OktaPreview', $true)
      }
      $maxLength = ($displayObject.Keys | ForEach-Object { $_.Length }) | Measure-Object -Maximum | Select-Object -ExpandProperty Maximum
      foreach ($item in $displayObject.GetEnumerator()) {
          $keyPadded = $item.Key.PadRight($maxLength)
          Write-Host "$keyPadded : $($item.Value)"
      }

      # If connected with the legacy method, recommend upgrading.
      if ($PSCmdlet.ParameterSetName -eq 'ApiToken') {
          Write-Host # Add a newline for spacing
          Write-Host -ForegroundColor Yellow "Recommendation: You've connected using a legacy API Token. For enhanced security, consider upgrading to the modern OAuth 2.0 flow."
          Write-Host -ForegroundColor Yellow "Run 'New-OktaOIDCApplication' for a guided setup, or see the Okta documentation for more details:"
          Write-Host -ForegroundColor Cyan "https://developer.okta.com/docs/api/openapi/okta-oauth/guides/overview/"
      }
    }
    catch {
      Write-Host -ForegroundColor Red    "Failed to connect to Okta"
      Write-Verbose "An error occurred during the connection process: $_"
      Write-Host -ForegroundColor Yellow "Verify your credentials, domain, and network connectivity."
      Write-Error $_
    }
  }
}