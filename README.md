# Table of Contents <!-- omit in toc -->
- [About PS-Okta Module](#about-ps-okta-module)
- [Features](#features)
- [Requirements](#requirements)
- [Quick Start (Interactive Setup)](#quick-start-interactive-setup)
- [Advanced Usage](#advanced-usage)
  - [Non-Interactive Authentication (Client Credentials)](#non-interactive-authentication-client-credentials)
- [Credits](#credits)
- [Version History](#version-history)

# About PS-Okta Module

PS-Okta is a powerful, unofficial PowerShell module designed to help Okta Administrators manage their organization quickly and efficiently from the command line. By interacting directly with the Okta REST API using PowerShell's native `Invoke-RestMethod`, this module provides a lightweight and dependency-free solution for automating administrative tasks.

## Features

- **Modern Authentication:** Connect securely using modern OAuth 2.0 grant types.
  - **Interactive (User-Based):** Implements the industry-standard Authorization Code Flow with PKCE for attended sessions, ensuring user credentials are never directly handled by the module. Other user-based flows like the Implicit Grant are not supported.
  - **Automation:** Client Credentials Flow for unattended, server-to-server scripts.
- **Automatic Token Refresh:** Sessions are automatically maintained in the background, providing a seamless experience.
- **Legacy Support:** Full backward compatibility for connecting with traditional Okta API tokens.
- **Guided Setup:** Includes a helper function (`New-OktaOIDCApplication`) to automatically create and configure the required Okta application for interactive OAuth authentication.

## Requirements

- PowerShell 7
- An Okta Application for authentication. You have three options:
  - **Recommended (Interactive):** A "Native" OIDC application using the Authorization Code Flow with PKCE. The module can help you create this automatically. See the Quick Start guide below.
  - **Recommended (Non-Interactive/Automation):** A "Service" OIDC application using the Client Credentials Flow. You will need the Client ID and Client Secret. See Advanced Usage.
  - **Legacy:** An Okta API Token. To create one:
    1. Sign in to your Okta Admin Console.
    2. Navigate to **Security** > **API**.
    3. Go to the **Tokens** tab and click **Create Token**.
    4. Give the token a descriptive name (e.g., "PS-Okta Module Token").
    5. **Important:** Copy the token value immediately. This is the only time it will be displayed.
    For more details, see the official Okta documentation.

## Quick Start (Interactive Setup)

This guide shows the recommended one-time setup to use the modern and secure OAuth 2.0 authentication flow for interactive, attended sessions.

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

4.  **Connect using your new Client ID!** For all future interactive sessions, you can now connect securely without needing the API token.
    ```powershell
    Connect-Okta -Domain "your-okta-domain" -ClientID "YOUR_COPIED_CLIENT_ID"
    ```

## Advanced Usage

### Non-Interactive Authentication (Client Credentials)

For automated scripts or running in a CI/CD pipeline, the Client Credentials flow is the recommended approach. This method does not require user interaction and avoids storing secrets in plaintext.

1.  **Create a "Service" (M2M) Application in Okta:**
    1.  In the Okta Admin Console, go to **Applications** > **Applications**.
    2.  Click **Create App Integration**.
    3.  Select **API Services** as the sign-on method and click **Next**.
    4.  Give the application a name (e.g., "PS-Okta Automation").
    5.  **Important:** Copy the **Client ID** and **Client secret**. You will need the secret in the next step.
    6.  Go to the **Okta API Scopes** tab for the new application and grant the necessary permissions (e.g., `okta.users.read`, `okta.groups.manage`).

2.  **Securely Store Your Client Secret:**
    Never store your client secret in plaintext within your scripts. The recommended approach is to convert it to an encrypted `SecureString` and save it to a file. You only need to do this once.

    ```powershell
    # Run this command once on the machine where the script will execute.
    # It will prompt you to securely enter your client secret.
    Read-Host -AsSecureString -Prompt "Enter your Okta Client Secret" | ConvertFrom-SecureString | Out-File -FilePath "C:\path\to\your\okta_client_secret.txt"
    ```
    **Security Note:** The `ConvertFrom-SecureString` cmdlet uses the Windows Data Protection API (DPAPI) to encrypt the secret. This means the resulting file is tied to the user account and the computer where it was created. It cannot be decrypted by a different user or on a different machine, providing a strong layer of security for credentials stored on disk.

3.  **Connect Using Client Credentials in Your Script:**
    In your automation script, you can now securely load the secret and connect. The `-Scopes` parameter is used to request the specific permissions your script needs.

    ```powershell
    # --- Script Configuration ---
    $clientId     = "YOUR_CLIENT_ID_HERE"
    $secretPath   = "C:\path\to\your\okta_client_secret.txt"
    $oktaDomain   = "your-okta-domain"
    
    # Define the API scopes your script needs. These must be granted to the application in Okta.
    $requiredScopes = @(
        "okta.users.read",
        "okta.groups.read",
        "okta.groups.manage"
    )

    # --- Connection Logic ---
    try {
        # Securely load the client secret from the encrypted file.
        $clientSecret = Get-Content -Path $secretPath | ConvertTo-SecureString

        # Connect non-interactively using the Client ID, the secure secret, and the required scopes.
        Connect-Okta -Domain $oktaDomain -ClientID $clientId -ClientSecret $clientSecret -Scopes $requiredScopes
    }
    catch {
        Write-Error "Failed to establish Okta connection. Please check configuration and credentials."
        # Use 'throw' to halt script execution if the connection is critical.
        throw
    }

    # --- Your Automation Logic Here ---
    # Example: Get all users and groups
    Get-OktaUser -Limit 100
    Get-OktaGroup -Limit 100
    ```
    For more advanced scenarios, consider using a dedicated secrets management solution like the `Microsoft.PowerShell.SecretManagement` module.

## Credits

New-DynamicParameter.ps1 credit to BeastMaster, jrich523 and ramblingcookiemonster here.

## Version History
* **0.3.0** - Added support for non-interactive authentication using the OAuth 2.0 Client Credentials Flow.
* **0.2.0** - Overhauled build system to be dependency-free. Refactored core API function for stability and corrected a major bug in pipeline output handling.
* **0.1.0** - Implemented OAuth 2.0 PKCE authentication, automatic token refresh, and a complete auth system overhaul.
* **0.0.4** - Additional functions
* **0.0.3** - Code revamp with helper functions
* **0.0.2** - Filename restructure
* **0.0.1** - Very first release
