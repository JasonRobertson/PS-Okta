<#
  .Synopsis
    Connect-Okta is used to establish the connection to the Organization Okta.
  .DESCRIPTION
    Connect-Okta is used to establish the connection to the Organization Okta. Requires an API Token generated within Okta Admin Portal.
  .EXAMPLE
    PS C:\> $secret = Read-Host -AsSecureString -Prompt 'Enter your Okta application client secret'
    PS C:\> Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg' -ClientSecret $secret

    Connected successfully to 'My Company' as 'My M2M App'
    
    CompanyName : My Company
    Domain      : my-org
    URI         : https://my-org.okta.com/api/v1
    User        : My M2M App
    UserID      : 0oa123456789abcdefg

    Connects to Okta using the recommended OAuth 2.0 Client Credentials flow. This is the preferred method for automation and service accounts.
  .EXAMPLE
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    PS C:\> $cred = Get-Credential -Message 'Enter your Okta API Token'
    PS C:\> Connect-Okta -Domain my-org -ApiToken $cred

    Connects to Okta using an API Token, securely prompting for the token. This is the recommended method for interactive administrative tasks.
  .INPUTS
    None
  .OUTPUTS
    A connection object is stored in the session. Status information is written to the host.
  .NOTES
    No other cmdlets will work without having run Connect-Okta first.
#>
function Connect-Okta {
  [CmdletBinding(DefaultParameterSetName='ClientCredentials')]
  param(
    [Parameter(ParameterSetName='ClientCredentials')]
    [Parameter(ParameterSetName='ApiToken')]
    [string]$Domain,

    # --- API Token Parameter Set ---
        [parameter(ParameterSetName='ApiToken')]
    [pscredential]$ApiToken,

    # --- Client Credentials Parameter Set (ClientSecret is unique to this set) ---
        [parameter(ParameterSetName='ClientCredentials')]
    [System.Security.SecureString]$ClientSecret,

    # --- Scopes for Client Credentials ---
    [parameter(ParameterSetName='ClientCredentials', HelpMessage = "Default: okta.apps.read, okta.orgs.read. Scopes required for the service principal.")]
    [string[]]$Scopes,

    # --- Common Parameters ---
    [switch]$Preview,

    # --- Client Credentials Parameter ---
    [parameter(ParameterSetName='ClientCredentials')]
    [string]$ClientID
  )
  process {
    # Guard clauses for mandatory parameters (must be outside try/catch)
    if (-not $PSBoundParameters.ContainsKey('Domain')) {
      throw "Parameter 'Domain' is required."
    }
    if ($PSCmdlet.ParameterSetName -eq 'ClientCredentials') {
      if (-not $PSBoundParameters.ContainsKey('ClientID')) {
        throw "Parameter 'ClientID' is required for ClientCredentials."
      }
      if (-not $PSBoundParameters.ContainsKey('ClientSecret')) {
        throw "Parameter 'ClientSecret' is required for ClientCredentials."
      }
    }
    if ($PSCmdlet.ParameterSetName -eq 'ApiToken' -and -not $PSBoundParameters.ContainsKey('ApiToken')) {
      throw "Parameter 'ApiToken' is required for ApiToken."
    }

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

      if ($PSCmdlet.ParameterSetName -eq 'ClientCredentials') {
        # Set default scopes for Client Credentials if not provided by the user
        if (-not $PSBoundParameters.ContainsKey('Scopes')) {
            # These are the minimum scopes required for Connect-Okta to retrieve app and org details.
            # Users can override this to request additional permissions for subsequent cmdlets.
            $Scopes = @('okta.apps.read', 'okta.orgs.read')
        }
        # Delegate the Client Credentials flow to its dedicated helper.
        $tokenResponse = New-OktaConnectionClientCreds -Domain $Domain -ClientID $ClientID -ClientSecret $ClientSecret -BaseUri $baseUri -Scopes $Scopes
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
        if ($PSCmdlet.ParameterSetName -eq 'ClientCredentials') {
            # For M2M auth, the "user" is the application itself. Fetch its details.
            Write-Verbose "Fetching application details for Client ID: $ClientID"
            $appDetails = Invoke-RestMethod -Method GET -Uri "$baseUri/api/v1/apps/$ClientID" -Headers $commonHeaders
            $requestor = [pscustomobject]@{ Id = $appDetails.id; profile = @{ login = $appDetails.label } }
        }
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
      if ($PSCmdlet.ParameterSetName -eq 'ClientCredentials') {
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
    }
    catch {
      Write-Host -ForegroundColor Red    "Failed to connect to Okta"
      Write-Verbose "An error occurred during the connection process: $_"
      Write-Host -ForegroundColor Yellow "Verify your credentials, domain, and network connectivity."
      Write-Error $_
    }
  }
}