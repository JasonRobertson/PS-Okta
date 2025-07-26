<#
  .SYNOPSIS
    Helps create and configure a new OIDC application in Okta for use with this module.
  .DESCRIPTION
    This function provides two modes to help a user configure the necessary Native OpenID Connect application in their Okta organization.

    Default Mode (Informational):
    Provides a step-by-step guide for manually creating the application in the Okta Admin Console, including the correct settings and links to documentation.

    Register Mode (-Register):
    Uses the Okta API to automatically create the application. This requires an active connection to Okta using an API Token with sufficient permissions (e.g., App Admin).
  .PARAMETER AppName
    The name for the new OIDC application in Okta.
  .PARAMETER RedirectUris
    The allowed callback URLs for the application. Defaults to the standard localhost URI used by Connect-Okta.
  .PARAMETER Register
    A switch to enable Automatic Registration Mode, which will create the application via the API.
  .PARAMETER AssignToCurrentUser
    When used with -Register, this switch assigns the new application to the currently authenticated admin user. This is the recommended option for admin tools.
  .PARAMETER AssignToGroup
    When used with -Register, this switch assigns the new application to a specific Okta group by name.
  .PARAMETER AssignToEveryone
    When used with -Register, this switch assigns the new application to the 'Everyone' group. Use with caution.
  .EXAMPLE
    PS C:\> New-OktaOIDCApplication -AppName "My PowerShell CLI Tool"

    --- Okta OIDC Application Setup Guide ---
    To use this module with modern OAuth 2.0, you need to register a 'Native Application' in your Okta organization.
    Here are the steps to do it manually:
    ...

    This example displays the informational guide for manually creating the application.
  .EXAMPLE
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
    PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
    PS C:\> New-OktaOIDCApplication -AppName "My PowerShell CLI Tool" -Register -AssignToCurrentUser
    
    whatif: Performing the operation "Create OIDC Application 'My PowerShell CLI Tool'" on target "Okta domain 'my-org'".
    whatif: Performing the operation "Assign application 'My PowerShell CLI Tool'" on target "User 'admin@example.com'".
    Successfully created application 'My PowerShell CLI Tool'.
    Your new Client ID is: 0oa123456789abcdefg
    Successfully assigned application to the current user (admin@example.com).
    Use it to connect: Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg'

    This example connects to Okta with an admin API token and then automatically creates and assigns the OIDC application to the admin running the command.
  .EXAMPLE
    # This example assumes you have already connected using an API token as shown in the previous example.
    # It creates an application with the default name.
    PS C:\> New-OktaOIDCApplication -Register -AssignToCurrentUser

    whatif: Performing the operation "Create OIDC Application 'PS-Okta PowerShell Module'" on target "Okta domain 'my-org'".
    whatif: Performing the operation "Assign application 'PS-Okta PowerShell Module'" on target "User 'admin@example.com'".
    Successfully created application 'PS-Okta PowerShell Module'.
    Your new Client ID is: 0oa987654321fedcba
    Successfully assigned application to the current user (admin@example.com).
    Use it to connect: Connect-Okta -Domain my-org -ClientID '0oa987654321fedcba'

    This example automatically creates an application with the default name 'PS-Okta PowerShell Module' and assigns it to the current user.
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
    [switch]$AssignToEveryone
  )

  if (-not $Register) {
    # --- Informational Mode ---
    Write-Host -ForegroundColor Cyan "--- Okta OIDC Application Setup Guide ---"
    Write-Host "To use this module with modern OAuth 2.0, you need to register a 'Native Application' in your Okta organization."
    Write-Host "Here are the steps to do it manually:"
    Write-Host
    Write-Host -ForegroundColor Yellow "1. Sign in to your Okta Admin Console."
    Write-Host -ForegroundColor Yellow "2. Navigate to Applications > Applications."
    Write-Host -ForegroundColor Yellow "3. Click 'Create App Integration'."
    Write-Host -ForegroundColor Yellow "4. Select 'OIDC - OpenID Connect' as the sign-in method."
    Write-Host -ForegroundColor Yellow "5. Select 'Native Application' as the Application type, then click Next."
    Write-Host -ForegroundColor Cyan "   (Note: A 'Native Application' is required for this module's interactive login flow. The 'API Service Integration' type is for non-interactive, machine-to-machine authentication)."
    Write-Host
    Write-Host -ForegroundColor Yellow "6. On the settings page, configure the following:"
    Write-Host "   - App integration name: '$AppName'"
    Write-Host "   - Grant type: Check 'Authorization Code' and 'Refresh Token'."
    Write-Host "   - Sign-in redirect URIs: Add the following URI -> '$($RedirectUris[0])'"
    Write-Host "   - Controlled access: Assign to everyone or specific groups as needed."
    Write-Host
    Write-Host -ForegroundColor Yellow "7. Click Save."
    Write-Host
    Write-Host -ForegroundColor Green "After saving, Okta will display the 'Client ID'. Copy this value."
    Write-Host "You will use it to connect with this module, like this:"
    Write-Host -ForegroundColor White "`nConnect-Okta -Domain your-domain -ClientID 'YOUR_COPIED_CLIENT_ID'`n"
    Write-Host -ForegroundColor Cyan "For more details, see the official Okta documentation:"
    Write-Host "https://developer.okta.com/docs/api/openapi/okta-oauth/guides/overview/"
    return
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

        # --- Application Assignment Logic ---
        if ($AssignToCurrentUser) {
            $userId = $script:connectionOkta.UserID
            if ($PSCmdlet.ShouldProcess("User '$($script:connectionOkta.User)'", "Assign application '$($newApp.label)'")) {
                Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/users/$userId" -ErrorAction Stop
                Write-Host -ForegroundColor Green "Successfully assigned application to the current user ($($script:connectionOkta.User))."
            }
        }
        elseif ($AssignToGroup) {
            if ($PSCmdlet.ShouldProcess("Group '$AssignToGroup'", "Assign application '$($newApp.label)'")) {
                $group = (Invoke-OktaAPI -Endpoint "groups?q=$AssignToGroup" -ErrorAction Stop) | Where-Object { $_.profile.name -eq $AssignToGroup }
                if ($group) {
                    Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/groups/$($group.id)" -ErrorAction Stop
                    Write-Host -ForegroundColor Green "Successfully assigned application to the '$AssignToGroup' group."
                } else {
                    Write-Warning "Could not find the group '$AssignToGroup' to assign the application."
                }
            }
        }
        elseif ($AssignToEveryone) {
            if ($PSCmdlet.ShouldProcess("Group 'Everyone'", "Assign application '$($newApp.label)'")) {
                $everyoneGroup = (Invoke-OktaAPI -Endpoint 'groups?q=Everyone' -ErrorAction Stop) | Where-Object { $_.profile.name -eq 'Everyone' }
                Invoke-OktaAPI -Method PUT -Endpoint "apps/$($newApp.id)/groups/$($everyoneGroup.id)" -ErrorAction Stop
                Write-Host -ForegroundColor Green "Successfully assigned application to the 'Everyone' group."
            }
        }

        Write-Host "Use it to connect: Connect-Okta -Domain $($script:connectionOkta.Domain) -ClientID '$($newApp.credentials.oauthClient.client_id)'"
    }
    catch {
        # Start with a base error message
        $finalErrorMessage = "Failed to create or configure the application. Please ensure your API Token has sufficient permissions (e.g., Application Administrator)."

        # The detailed error from Okta is often in the ErrorDetails message of the ErrorRecord
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) {
            try {
                $oktaError = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
                if ($oktaError -and $oktaError.errorSummary) {
                    $finalErrorMessage += "`nOkta API Error: $($oktaError.errorSummary)"
                }
            } catch {
                # If parsing fails, it's not JSON. Just append the raw message.
                $finalErrorMessage += "`nRaw API Response: $($_.ErrorDetails.Message)"
            }
        } else {
            # Fallback to the main exception message if ErrorDetails is not available
            $finalErrorMessage += "`nException: $($_.Exception.Message)"
        }

        throw $finalErrorMessage
    }
  }
}
