<#
.SYNOPSIS
  A private helper function that displays a manual guide for creating an OIDC application in the Okta Admin Console.
.DESCRIPTION
  This function is called by New-OktaOIDCApplication when it is run in its default, informational mode. It provides
  step-by-step instructions for an administrator to follow.
#>
function Show-OktaOIDCApplicationGuide {
    [CmdletBinding()]
    param()

    Write-Host -ForegroundColor Cyan "--- Manual OIDC Application Setup Guide ---"
    Write-Host "This guide will walk you through creating a Native OIDC application in Okta for use with this PowerShell module."
    Write-Host "This is required for the interactive `Connect-Okta -ClientID ...` command."
    Write-Host
    Write-Host -ForegroundColor Yellow "1. Log in to your Okta Admin Console."
    Write-Host
    Write-Host -ForegroundColor Yellow "2. Navigate to Applications > Applications."
    Write-Host
    Write-Host -ForegroundColor Yellow "3. Click 'Create App Integration'."
    Write-Host
    Write-Host -ForegroundColor Yellow "4. Select 'OIDC - OpenID Connect' as the sign-in method."
    Write-Host
    Write-Host -ForegroundColor Yellow "5. Select 'Native Application' as the application type, then click Next."
    Write-Host
    Write-Host -ForegroundColor Yellow "6. Configure the application with the following settings:"
    Write-Host "   - App integration name: Choose a descriptive name (e.g., 'PS-Okta PowerShell Module')."
    Write-Host "   - Grant type: Ensure 'Authorization Code' is checked."
    Write-Host "   - Sign-in redirect URIs: Add 'http://localhost:8080/'"
    Write-Host "   - Controlled access: Assign the application to the appropriate users or groups."
    Write-Host
    Write-Host -ForegroundColor Yellow "7. Click Save."
    Write-Host
    Write-Host -ForegroundColor Yellow "8. Grant API Scopes:"
    Write-Host "   - After saving, go to the 'API Scopes' tab for your new application."
    Write-Host "   - Click 'Grant' and add the following two scopes:"
    Write-Host "     - okta.users.read.self"
    Write-Host "     - okta.orgs.read"
    Write-Host
    Write-Host -ForegroundColor Green "After saving, Okta will display the 'Client ID'. Copy this value."
    Write-Host "You will use it to connect with this module, like this:"
    Write-Host -ForegroundColor White "`nConnect-Okta -Domain your-domain -ClientID 'YOUR_COPIED_CLIENT_ID'`n"
}