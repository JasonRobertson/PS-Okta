<#
  .SYNOPSIS
    Helps create and configure a new OIDC application in Okta for use with this module.
  .DESCRIPTION
    This function provides two modes to help a user configure the necessary Native OpenID Connect application in their Okta organization.

    Default Mode (Informational):
    Provides a step-by-step guide for manually creating the application in the Okta Admin Console, including the correct settings and links to documentation.

    Register Mode (-Register):
    Uses the Okta API to automatically create the application. This requires an active connection to Okta using an API Token with sufficient permissions (e.g., App Admin). By default, the new application is assigned to the current admin user.
  .PARAMETER AppName
    The name for the new OIDC application in Okta.
  .PARAMETER RedirectUris
    The allowed callback URLs for the application. Defaults to the standard localhost URI used by Connect-Okta.
  .PARAMETER Register
    A switch to enable Automatic Registration Mode, which will create the application via the API.
  .PARAMETER AssignToCurrentUser
    When used with -Register, this switch assigns the new application to the currently authenticated admin user. This is the default behavior if no other assignment method is specified.
  .PARAMETER AssignToGroup
    When used with -Register, this switch assigns the new application to a specific Okta group by name.
  .PARAMETER AssignToEveryone
    When used with -Register, this switch assigns the new application to the 'Everyone' group. Use with caution.
  .PARAMETER Scope
    Specifies additional API scopes to grant to the new application. The base scopes 'okta.users.read.self' and 'okta.orgs.read' are always included to ensure `Connect-Okta` can function.
    You can provide a list of any valid Okta API scopes. This parameter supports tab-completion for all available scopes.
    For a detailed description of each scope, see the Okta documentation: https://developer.okta.com/docs/api/oauth2/#okta-admin-management
  .PARAMETER AssignAdminRole
    A convenience parameter to grant all the API scopes associated with a default Okta admin role (e.g., 'Group Administrator'). These are added to the base scopes required for the module to function. This parameter supports tab-completion.
    For a detailed description of what each role can do, see the Okta documentation: https://help.okta.com/oie/en-us/content/topics/security/administrators-admin-comparison.htm
  .EXAMPLE
    PS C:\> New-OktaOIDCApplication

    --- Manual OIDC Application Setup Guide ---
    This guide will walk you through creating a Native OIDC application in Okta...
    ...

    This example shows the default behavior, which is to display the informational guide for manually creating the application.
  .EXAMPLE
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
    PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
    PS C:\> New-OktaOIDCApplication -AppName "My PowerShell CLI Tool" -Register
    
    Successfully created application 'My PowerShell CLI Tool'.
    Your new Client ID is: 0oa123456789abcdefg
    Successfully granted the following API scopes:
     - okta.users.read.self
     - okta.orgs.read
    Successfully assigned application to the current user (admin@example.com).
    Use it to connect: Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg'
    
    This example connects to Okta with an admin API token and then automatically creates the OIDC application. By default, it is assigned to the admin user running the command.
  .EXAMPLE
    # This example assumes you have already connected using an API token as shown in the previous example.
    # It creates an application and assigns it to the 'Everyone' group instead of the default user.
    PS C:\> New-OktaOIDCApplication -Register -AssignToEveryone

    Successfully created application 'PS-Okta PowerShell Module'.
    Your new Client ID is: 0oa987654321fedcba
    Successfully granted the following API scopes:
     - okta.users.read.self
     - okta.orgs.read
    Successfully assigned application to the 'Everyone' group.
    Use it to connect: Connect-Okta -Domain my-org -ClientID '0oa987654321fedcba'

    This example automatically creates an application with the default name 'PS-Okta PowerShell Module' and assigns it to the 'Everyone' group.
  .EXAMPLE
    # This example creates an application with specific scopes for managing users.
    PS C:\> $userAdminScopes = @('okta.users.read', 'okta.users.manage')
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
    [Parameter(ParameterSetName='Assign')]
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

  # Validate that only one assignment method is used
  $assignmentParams = @($PSBoundParameters.ContainsKey('AssignToCurrentUser'), $PSBoundParameters.ContainsKey('AssignToGroup'), $PSBoundParameters.ContainsKey('AssignToEveryone'))
  if (($assignmentParams | Where-Object { $_ }).Count -gt 1) {
      Write-Error "Please specify only one assignment method: -AssignToCurrentUser, -AssignToGroup, or -AssignToEveryone."
      return
  }

  if ($PSCmdlet.ShouldProcess("Okta domain '$($script:connectionOkta.Domain)'", "Create OIDC Application '$AppName'")) {
    $appPayload = @{
      name        = "oidc_client" # Use the generic OIDC template
      label       = $AppName
      signOnMode  = "OPENID_CONNECT"
      credentials = @{
        oauthClient = @{
          token_endpoint_auth_method = "none" # Required for public clients using PKCE
        }
      }
      settings    = @{
        oauthClient = @{
          application_type = "native"
          grant_types      = @("authorization_code", "refresh_token")
          # Only include the response type required for the Authorization Code Flow to avoid conflicts.
          response_types   = @("code")
          redirect_uris    = $RedirectUris
        }
      }
    }

    try {
        Write-Verbose "Sending request to create application..."
        $newApp = Invoke-OktaAPI -Method POST -Endpoint 'apps' -Body $appPayload -ErrorAction Stop

        Write-Host -ForegroundColor Green "Successfully created application '$($newApp.label)'."
        Write-Host "Your new Client ID is: $($newApp.credentials.oauthClient.client_id)"

        # --- Grant Required API Scopes ---
        # This step is crucial for the OAuth connection to be able to read user and org details.
        # Start with the minimum required scopes and add any custom scopes requested.
        $scopesToGrant = @('okta.users.read.self', 'okta.orgs.read')
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
        $failedScopes  = [System.Collections.Generic.List[pscustomobject]]::new()
        foreach ($scopeId in $scopesToGrant) {
            if ($PSCmdlet.ShouldProcess("Scope '$scopeId'", "Grant to application '$($newApp.label)'")) {
                try {
                    $grantPayload = @{
                        scopeId = $scopeId
                        issuer  = $issuerUri
                    }
                    # Invoke the API. The internal Invoke-OktaAPI function will handle rate-limit retries automatically.
                    Invoke-OktaAPI -Method POST -Endpoint "apps/$($newApp.id)/grants" -Body $grantPayload -ErrorAction Stop | Out-Null
                    Write-Verbose "Successfully granted scope '$scopeId'."
                    $grantedScopes.Add($scopeId)
                } catch {
                    # If Invoke-OktaAPI fails after all retries, it throws a terminating error. We catch it here.
                    # Attempt to parse a clean error message from the API's JSON response.
                    $reason = $_.Exception.Message
                    try {
                        $responseStream = $_.Exception.Response.GetResponseStream()
                        $streamReader = New-Object System.IO.StreamReader($responseStream)
                        $jsonBody = $streamReader.ReadToEnd()
                        $streamReader.Close()
                        $responseStream.Close()

                        $errorObject = $jsonBody | ConvertFrom-Json
                        if ($errorObject.errorSummary) {
                            $reason = $errorObject.errorSummary
                            if ($errorObject.errorCauses[0].errorSummary) {
                                $reason += " ($($errorObject.errorCauses[0].errorSummary))"
                            }
                        }
                    }
                    catch {
                        # Fallback to the original exception message if parsing fails.
                    }
                    $failedScopes.Add([pscustomobject]@{Scope = $scopeId; Reason = $reason})
                }
            }
        }

        if ($grantedScopes.Count -gt 0) {
            Write-Host -ForegroundColor Green "Successfully granted the following API scopes:"
            $grantedScopes | Sort-Object | ForEach-Object { Write-Host " - $_" }
        }

        # After attempting all grants, show a single, consolidated warning for any that failed.
        if ($failedScopes.Count -gt 0) {
            Write-Warning "Failed to automatically grant the following $($failedScopes.Count) scope(s). You may need to grant them manually."
            $failedScopes | Sort-Object -Property Scope | ForEach-Object {
                # Use Write-Host for better formatting control of the detailed reasons.
                Write-Host -ForegroundColor Yellow " - Scope:  $($_.Scope)"
                Write-Host -ForegroundColor Yellow "   Reason: $($_.Reason)"
            }
        }

        # --- Application Assignment Logic ---
        # Determine if an explicit assignment method was chosen by the user.
        $assignmentMethodSpecified = $PSBoundParameters.ContainsKey('AssignToCurrentUser') -or $PSBoundParameters.ContainsKey('AssignToGroup') -or $PSBoundParameters.ContainsKey('AssignToEveryone')

        # Default to assigning to the current user if no other assignment method is specified.
        if ($AssignToCurrentUser -or (-not $assignmentMethodSpecified)) {
            $userId = $script:connectionOkta.UserID
            if ($PSCmdlet.ShouldProcess("User '$($script:connectionOkta.User)'", "Assign application '$($newApp.label)'")) {
                Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/users/$userId" -ErrorAction Stop | Out-Null
                Write-Host -ForegroundColor Green "Successfully assigned application to the current user ($($script:connectionOkta.User))."
            }
        }
        elseif ($AssignToGroup) {
            if ($PSCmdlet.ShouldProcess("Group '$AssignToGroup'", "Assign application '$($newApp.label)'")) {
                $group = (Invoke-OktaAPI -Endpoint "groups?q=$AssignToGroup" -ErrorAction Stop) | Where-Object { $_.profile.name -eq $AssignToGroup }
                if ($group) {
                    Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/groups/$($group.id)" -ErrorAction Stop | Out-Null
                    Write-Host -ForegroundColor Green "Successfully assigned application to the '$AssignToGroup' group."
                } else {
                    Write-Warning "Could not find the group '$AssignToGroup' to assign the application."
                }
            }
        }
        elseif ($AssignToEveryone) {
            if ($PSCmdlet.ShouldProcess("Group 'Everyone'", "Assign application '$($newApp.label)'")) {
                $everyoneGroup = (Invoke-OktaAPI -Endpoint 'groups?q=Everyone' -ErrorAction Stop) | Where-Object { $_.profile.name -eq 'Everyone' }
                Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/groups/$($everyoneGroup.id)" -ErrorAction Stop | Out-Null
                Write-Host -ForegroundColor Green "Successfully assigned application to the 'Everyone' group."
            }
        }

        Write-Host "Use it to connect: Connect-Okta -Domain $($script:connectionOkta.Domain) -ClientID '$($newApp.credentials.oauthClient.client_id)'"
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
