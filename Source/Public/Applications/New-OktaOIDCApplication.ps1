<#
  .SYNOPSIS
    Helps create and configure a new Service (M2M) OIDC application in Okta for use with this module.
  .DESCRIPTION
    This function helps an administrator create and configure the necessary Service (Machine-to-Machine) OpenID Connect application in their Okta organization. This type of application is required for unattended automation using the Client Credentials flow (`Connect-Okta -ClientCredentials`).

    Default Mode (Informational):
    Provides a step-by-step guide for manually creating the application in the Okta Admin Console.

    Register Mode (-Register):
    Uses the Okta API to automatically create the application. This requires an active connection to Okta using an API Token with sufficient permissions (e.g., App Admin). The function will output the generated Client ID and Client Secret, which are needed to connect.
  .PARAMETER AppName
    The name for the new OIDC application in Okta.
  .PARAMETER Register
    A switch to enable Automatic Registration Mode, which will create the application via the API.
  .PARAMETER Scope
    Specifies API scopes to grant to the new service application. The base scopes 'okta.apps.read' and 'okta.orgs.read' are always included to ensure `Connect-Okta` can function.
    You can provide a list of any valid Okta API scopes. This parameter supports tab-completion for all available scopes.
    For a detailed description of each scope, see the Okta documentation: https://developer.okta.com/docs/api/oauth2/#okta-admin-management
  .PARAMETER AssignAdminRole
    A convenience parameter to grant all the API scopes associated with a default Okta admin role (e.g., 'Group Administrator'). These are added to the base scopes required for the module to function. This parameter supports tab-completion.
    For a detailed description of what each role can do, see the Okta documentation: https://help.okta.com/oie/en-us/content/topics/security/administrators-admin-comparison.htm
  .EXAMPLE
    PS C:\> New-OktaOIDCApplication

    --- Manual Service Application Setup Guide ---
    This guide will walk you through creating a Service (M2M) OIDC application in Okta...
    ...

    This example shows the default behavior, which is to display the informational guide for manually creating the application.
  .EXAMPLE
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
    PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
    PS C:\> New-OktaOIDCApplication -AppName "PowerShell Automation" -Register -AssignAdminRole "Read-only Administrator"
    
    Successfully created application 'PowerShell Automation'.
    Your new Client ID is: 0oa123456789abcdefg
    
    ********************************** IMPORTANT **********************************
    Your Client Secret is: aBcDeFg...xyz
    This is the ONLY time the secret will be displayed. Store it securely now.
    *******************************************************************************

    Successfully granted the following API scopes:
     - okta.apps.read
     - okta.orgs.read
     - ... (other read-only scopes)
    Use it to connect: $secret = Read-Host -AsSecureString; Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg' -ClientSecret $secret
    
    PS C:\> New-OktaOIDCApplication -AppName "User Management Tool" -Register -Scope $userAdminScopes

    Successfully created application 'User Management Tool'.
    Your new Client ID is: 0oa...
    Successfully granted the following API scopes:
     - okta.users.read
     - okta.users.manage
    Successfully assigned application to the current user (admin@example.com).

    This example creates an application and grants it specific permissions for user administration, overriding the default scopes.
  .EXAMPLE
    # This example creates an application and grants it all the scopes of a Group Administrator.
    PS C:\> New-OktaOIDCApplication -AppName "Group Management Tool" -Register -AssignAdminRole "Group Administrator"

    Successfully created application 'Group Management Tool'.
    Your new Client ID is: 0oa...
    Successfully granted the following API scopes:
     - okta.groups.manage
     - okta.users.read
    Successfully assigned application to the current user (admin@example.com).

    This example uses a role-based scope assignment, which is simpler than specifying individual scopes.
  .EXAMPLE
    # This example creates an application with all the permissions of a Super Administrator.
    PS C:\> New-OktaOIDCApplication -AppName "Super Admin Tool" -Register -AssignAdminRole "Super Administrator"

    Successfully created application 'Super Admin Tool'.
    Your new Client ID is: 0oa...
    Successfully granted the following API scopes:
     - okta.apps.manage
     - okta.apps.read
     ...
    Successfully assigned application to the current user (admin@example.com).

    This example grants all available API scopes to the application, which is useful for a tool that needs full administrative access.
  .NOTES
    The automatic registration mode requires a connection established with `Connect-Okta -ApiToken ...`.
    The resulting Client ID is used with `Connect-Okta -ClientID ...`.
#>
function New-OktaOIDCApplication {
  [CmdletBinding(SupportsShouldProcess)]
  param(
    [Parameter()]
    [string]$AppName = 'PS-Okta PowerShell Module',
    [Parameter()]
    [string[]]$RedirectUris = @('http://localhost:8080/'),
    [Parameter()]
    [switch]$Register,
    [Parameter(ParameterSetName='Assign')]
    [switch]$AssignToCurrentUser,
    [Parameter(ParameterSetName='Assign')]
    [string]$AssignToGroup,
    [Parameter(ParameterSetName='Assign')]
    [switch]$AssignToEveryone,
    [Parameter(ParameterSetName='Assign')]
    [ValidateSet(
        'API Access Management Administrator',
        'Application Administrator',
        'Group Administrator',
        'Group Membership Administrator',
        'Help Desk Administrator',
        'Organizational Administrator',
        'Read-only Administrator',
        'Report Administrator',
        'User Administrator',
        'Super Administrator'
    )]
    [string[]]$AssignAdminRole,
    [Parameter()]
    [ValidateSet(
        'okta.administrators.manage',
        'okta.administrators.read',
        'okta.apiTokens.manage',
        'okta.apiTokens.read',
        'okta.apps.manage',
        'okta.apps.read',
        'okta.authenticators.manage',
        'okta.authenticators.read',
        'okta.authorizationServers.manage',
        'okta.authorizationServers.read',
        'okta.brands.manage',
        'okta.brands.read',
        'okta.clients.manage',
        'okta.clients.read',
        'okta.clients.register',
        'okta.deviceAssurancePolicies.manage',
        'okta.deviceAssurancePolicies.read',
        'okta.devices.manage',
        'okta.devices.read',
        'okta.domains.manage',
        'okta.domains.read',
        'okta.eventHooks.manage',
        'okta.eventHooks.read',
        'okta.factors.manage',
        'okta.factors.read',
        'okta.groups.manage',
        'okta.groups.members.manage',
        'okta.groups.members.read',
        'okta.groups.read',
        'okta.idps.manage',
        'okta.idps.read',
        'okta.inlineHooks.manage',
        'okta.inlineHooks.read',
        'okta.linkedObjects.manage',
        'okta.linkedObjects.read',
        'okta.logs.read',
        'okta.networkZones.manage',
        'okta.networkZones.read',
        'okta.orgs.manage',
        'okta.orgs.read',
        'okta.policies.manage',
        'okta.policies.read',
        'okta.profileMappings.manage',
        'okta.profileMappings.read',
        'okta.rateLimits.manage',
        'okta.rateLimits.read',
        'okta.resourceSets.manage',
        'okta.resourceSets.read',
        'okta.roles.manage',
        'okta.roles.read',
        'okta.schemas.manage',
        'okta.schemas.read',
        'okta.sessions.manage',
        'okta.sessions.read',
        'okta.templates.manage',
        'okta.templates.read',
        'okta.threatInsights.read',
        'okta.trustedOrigins.manage',
        'okta.trustedOrigins.read',
        'okta.userTypes.manage',
        'okta.userTypes.read',
        'okta.users.credentials.manage',
        'okta.users.lifecycle.manage',
        'okta.users.manage',
        'okta.users.manage.self',
        'okta.users.read',
        'okta.users.read.self',
        'okta.workflows.invoke',
        'okta.workflows.manage',
        'okta.workflows.read'
    )]
    [string[]]$Scope
  )

  if (-not $PSBoundParameters.ContainsKey('Register')) {
    Show-OktaOIDCApplicationGuide
    return # Exit after showing the guide
  }

  # --- Automatic Registration Mode ---
  if (-not (Test-OktaConnection -Quiet)) {
    Write-Error "An active Okta connection is required to register an application. Please connect first using 'Connect-Okta -ApiToken ...'."
    return
  }

  if ($script:connectionOkta.Tokens) {
    Write-Error "Application registration must be performed using a legacy Admin API Token, not an OAuth session."
    return
  }

  if ($PSCmdlet.ShouldProcess("Okta domain '$($script:connectionOkta.Domain)'", "Create OIDC Application '$AppName'")) {
    $appPayload = @{
      name        = "oidc_client" # Use the generic OIDC template
      label       = $AppName
      signOnMode  = "OPENID_CONNECT"
      settings    = @{
        oauthClient = @{
          application_type = "service"
          grant_types      = @("client_credentials")
          token_endpoint_auth_method = "client_secret_post"
        }
      }
    }

    try {
        Write-Verbose "Sending request to create application..."
        $newApp = Invoke-OktaAPI -Method POST -Endpoint 'apps' -Body $appPayload -ErrorAction Stop

        Write-Host -ForegroundColor Green "Successfully created application '$($newApp.label)'."
        $clientId = $newApp.credentials.oauthClient.client_id
        $clientSecret = $newApp.credentials.oauthClient.client_secret
        Write-Host "Your new Client ID is: $clientId"

        if ($clientSecret) {
            Write-Host
            Write-Host -ForegroundColor Black -BackgroundColor Yellow "********************************** IMPORTANT **********************************"
            Write-Host -ForegroundColor Black -BackgroundColor Yellow "Your Client Secret is: $clientSecret"
            Write-Host -ForegroundColor Black -BackgroundColor Yellow "This is the ONLY time the secret will be displayed. Store it securely now."
            Write-Host -ForegroundColor Black -BackgroundColor Yellow "*******************************************************************************"
            Write-Host
        }

        # --- Grant Required API Scopes ---
        $scopesToGrant = @('okta.apps.read', 'okta.orgs.read')
        if ($PSBoundParameters.ContainsKey('AssignAdminRole') -and $AssignAdminRole) {
            # Special handling for Super Administrator to ensure all available scopes are granted.
            if ($AssignAdminRole -contains 'Super Administrator') {
                try {
                    # Dynamically get all possible scopes from this function's -Scope parameter ValidateSet.
                    $command = Get-Command 'New-OktaOIDCApplication'
                    $scopeParameter = $command.Parameters['Scope']
                    $validateSetAttribute = $scopeParameter.Attributes.Where({$_.TypeId -eq [System.Management.Automation.ValidateSetAttribute]})
                    $scopesToGrant += $validateSetAttribute.ValidValues
                } catch {
                    Write-Warning "Could not dynamically determine all scopes for Super Administrator. Please report this issue."
                }
            }

            # Handle all other roles from the map.
            $otherRoles = $AssignAdminRole | Where-Object { $_ -ne 'Super Administrator' }
            if ($otherRoles) {
                $roleScopeMap = Get-OktaRoleScopeMap
                $otherRoles | ForEach-Object { $scopesToGrant += $roleScopeMap[$_] }
            }
        }
        if ($PSBoundParameters.ContainsKey('Scope')) {
            $scopesToGrant += $Scope
        }
        $scopesToGrant = $scopesToGrant | Select-Object -Unique

        $issuerUri     = $script:connectionOkta.URI.Replace('/api/v1', '') # Get base URI like https://domain.okta.com
        $grantedScopes = [System.Collections.Generic.List[string]]::new()
        foreach ($scopeId in $scopesToGrant) {
            $maxRetries = 3
            $retryCount = 0
            $success = $false
            if ($PSCmdlet.ShouldProcess("Scope '$scopeId'", "Grant to application '$($newApp.label)'")) {
                while ($retryCount -lt $maxRetries -and -not $success) {
                    try {
                        $grantPayload = @{
                            scopeId = $scopeId
                            issuer  = $issuerUri
                        }
                        Invoke-OktaAPI -Method POST -Endpoint "apps/$($newApp.id)/grants" -Body $grantPayload -ErrorAction Stop | Out-Null
                        Write-Verbose "Successfully granted scope '$scopeId'."
                        $grantedScopes.Add($scopeId)
                        $success = $true
                    } catch {
                        if ($_.Exception.Response.StatusCode -eq 429 -or ($_.ToString() -match 'E0000047')) {
                            $retryCount++
                            $backoffSeconds = [math]::Pow(2, $retryCount)
                            Write-Warning "Rate limit hit while granting '$scopeId'. Retrying in $backoffSeconds seconds... (Attempt $retryCount of $maxRetries)"
                            Start-Sleep -Seconds $backoffSeconds
                        } else {
                            Write-Warning "Failed to automatically grant scope '$scopeId'. You may need to grant it manually in the Okta Admin Console under the application's 'API Scopes' tab. Error: $_"
                            break # Break the while loop for this scope on non-retriable errors
                        }
                    }
                }
            }
        }

        if ($grantedScopes.Count -gt 0) {
            Write-Host -ForegroundColor Green "Successfully granted the following API scopes:"
            $grantedScopes | ForEach-Object { Write-Host " - $_" }
        }

        Write-Host "Use it to connect: `$secret = Read-Host -AsSecureString; Connect-Okta -Domain $($script:connectionOkta.Domain) -ClientID '$clientId' -ClientSecret `$secret"
    }
    catch {
        # Attempt to parse a more specific error message from the Okta API response.
        $errorMessage = "Failed to create or configure the application. Please ensure your API Token has sufficient permissions (e.g., Application Administrator)."
        $oktaError = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue

        if ($oktaError -and $oktaError.errorSummary) {
            $errorMessage += " Okta API Error: $($oktaError.errorSummary)"
        }
        else {
            # Fallback to the base exception message if a specific Okta error can't be parsed.
            $errorMessage += " Exception: $($_.Exception.Message)"
        }

        # Create a new ErrorRecord that includes our user-friendly message but preserves the original exception details.
        $newErrorRecord = [System.Management.Automation.ErrorRecord]::new($_.Exception, "ApplicationCreationFailure", [System.Management.Automation.ErrorCategory]::InvalidOperation, $null)
        $newErrorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($errorMessage)
        $PSCmdlet.ThrowTerminatingError($newErrorRecord)
    }
  }
}
