# Table of Contents <!-- omit in toc -->
- [About PS-Okta Module](#about-ps-okta-module)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Credits](#credits)
- [Version History](#version-history)

# About PS-Okta Module

PS-Okta is a powerful, unofficial PowerShell module designed to help Okta Administrators manage their organization quickly and efficiently from the command line. By interacting directly with the Okta REST API using PowerShell's native `Invoke-RestMethod`, this module provides a lightweight and dependency-free solution for automating administrative tasks.

## Features

- **Modern Authentication:** Connect securely using the OAuth 2.0 Authorization Code Flow with PKCE.
- **Automatic Token Refresh:** Sessions are automatically maintained in the background, providing a seamless experience.
- **Legacy Support:** Full backward compatibility for connecting with traditional Okta API tokens.
- **Guided Setup:** Includes a helper function (`New-OktaOIDCApplication`) to automatically create and configure the required Okta application for OAuth authentication.

## Requirements

- PowerShell 7
- An Okta Application for authentication. You have two options:
  - **Recommended (OAuth 2.0):** A "Native" OIDC application. The module can help you create this automatically. See the Quick Start guide below.
  - **Legacy:** An Okta API Token. To create one:
    1. Sign in to your Okta Admin Console.
    2. Navigate to **Security** > **API**.
    3. Go to the **Tokens** tab and click **Create Token**.
    4. Give the token a descriptive name (e.g., "PS-Okta Module Token").
    5. **Important:** Copy the token value immediately. This is the only time it will be displayed.
    For more details, see the [official Okta documentation](https://help.okta.com/oie/en-us/content/topics/security/api/api-token-mgmt.htm).

## Quick Start

This guide shows the recommended one-time setup to use the modern and secure OAuth 2.0 authentication flow.

1.  **Install the module:**
    ```powershell
    Install-Module -Name PS-Okta -Scope CurrentUser
    ```

2.  **Perform a one-time connection using a legacy API token** to create the new application. You will need an API token with permissions to manage applications.
    ```powershell
    # This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
    $cred = Get-Credential -Message "Enter your Okta Admin API Token for one-time setup"
    Connect-Okta -Domain "your-okta-domain" -ApiToken $cred
    ```

3.  **Run the setup helper** to automatically create and assign the new OIDC application.
    ```powershell
    New-OktaOIDCApplication -Register -AssignToCurrentUser
    # Copy the 'Client ID' from the output of this command.
    ```

4.  **Connect using your new Client ID!** For all future sessions, you can now connect securely without needing the API token.
    ```powershell
    Connect-Okta -Domain "your-okta-domain" -ClientID "YOUR_COPIED_CLIENT_ID"
    ```

## Credits

New-DynamicParameter.ps1 credit to BeastMaster, jrich523 and ramblingcookiemonster [here](https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1).

## Version History
* **0.2.0** - Overhauled build system to be dependency-free. Refactored core API function for stability and corrected a major bug in pipeline output handling.
* **0.1.0** - Implemented OAuth 2.0 PKCE authentication, automatic token refresh, and a complete auth system overhaul.
* **0.0.4** - Additional functions
* **0.0.3** - Code revamp with helper functions
* **0.0.2** - Filename restructure
* **0.0.1** - Very first release
