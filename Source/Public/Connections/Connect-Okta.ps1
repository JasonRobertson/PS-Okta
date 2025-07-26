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
    [string[]]$Scopes = @('openid', 'profile', 'email', 'offline_access', 'okta.users.read.self', 'okta.orgs.read'),

    # --- Common Parameters ---
    [switch]$Preview
  )
  process {
    try {
      # Initialize a hashtable to gather all connection properties
      $requestor     = $null
      $tokenResponse = $null

      Write-Verbose "Determining Okta base URI..."
      $baseUri = switch ($Preview){
        true  {-join ('https://',$Domain,'.oktapreview.com')}
        false {-join ('https://',$Domain,'.okta.com')}
      }
      Write-Verbose "Using base URI: $baseUri"

      if ($PSCmdlet.ParameterSetName -eq 'OAuth') {
        # Delegate the entire OAuth 2.0 connection flow to a private helper function.
        $tokenResponse = New-OktaConnectionOAuth -Domain $Domain -ClientID $ClientID -RedirectUri $RedirectUri -Scopes $Scopes -BaseUri $baseUri
      }
      else { # ApiToken Parameter Set
        # Delegate the API Token connection flow to a private helper function.
        $requestor = New-OktaConnectionApiToken -ApiToken $ApiToken -BaseUri $baseUri
      }

      # Common connection success logic: Fetch user and org details
      Write-Verbose "Fetching user and organization details to populate connection object."
      $authHeader = if ($tokenResponse) { "Bearer $($tokenResponse.access_token)" } else { "SSWS $($apiToken.GetNetworkCredential().password)" }
      $commonHeaders = @{ Accept = 'application/json'; Authorization = $authHeader }

      if ($null -eq $requestor) {
        Write-Verbose "Fetching user details from /api/v1/users/me."
        $requestor = Invoke-RestMethod -Method GET -Uri "$baseUri/api/v1/users/me" -Headers $commonHeaders
      }

      Write-Verbose "Fetching organization details from /api/v1/org."
      $organization = Invoke-RestMethod -Method GET -Uri "$baseUri/api/v1/org" -Headers $commonHeaders

      # Create the final, complete connection object with a defined order
      Write-Verbose "Updating connection object with user: $($requestor.profile.login) and company: $($organization.CompanyName)."
      $connectionObject = [ordered]@{
          CompanyName = $organization.CompanyName
          Domain      = $Domain
          URI         = "$baseUri/api/v1"
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

      # Display the connection details using the standard Get-OktaConnection cmdlet for consistency.
      Get-OktaConnection -IncludeOktaScopes
      
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