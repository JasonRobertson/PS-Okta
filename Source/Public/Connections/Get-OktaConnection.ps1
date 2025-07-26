<#
.SYNOPSIS
  Displays details about the current, active connection to an Okta organization.
.DESCRIPTION
  This function retrieves the stored session object and displays key information about the connection,
  including the connection type (OAuth 2.0 or legacy API Token), user details, and standard OIDC scopes.
  To view the specific Okta administrative scopes for an OAuth 2.0 connection, use the -IncludeOktaScopes switch.
.PARAMETER IncludeOktaScopes
  When specified for an OAuth 2.0 connection, this switch includes the detailed list of Okta administrative scopes (e.g., 'okta.users.read') in the output.
.EXAMPLE
  PS C:\> Get-OktaConnection

  CompanyName    : My Company
  Domain         : my-org
  URI            : https://my-org.okta.com/api/v1
  User           : admin@example.com
  UserID         : 00u123...
  ConnectionType : OAuth 2.0
  ClientName     : PS-Okta PowerShell Module
  ClientID       : 0oa456...
  Scopes         : - email
                   - offline_access
                   - openid
                   - profile
  OktaScopes     : 2 (use -IncludeOktaScopes to view)

  Displays a summary of the current active session, indicating that additional Okta-specific scopes are present.
.EXAMPLE
  PS C:\> Get-OktaConnection -IncludeOktaScopes

  ...
  Scopes         : - email
                   - offline_access
                   - openid
                   - profile
  OktaScopes     : - okta.orgs.read
                   - okta.users.read.self

  Displays the full list of both standard and Okta-specific API scopes for the current session, separated into their own properties.
.NOTES
  This command does not make any API calls itself, except for an optional call to retrieve the Client Name for OAuth connections.
#>
function Get-OktaConnection {
  [CmdletBinding()]
  [OutputType([pscustomobject])]
  param (
    [switch]$IncludeOktaScopes
  )

  if ($null -eq $script:connectionOkta) {
    Write-Warning "Not connected to Okta. Please run Connect-Okta first."
    return
  }

  # Build the output object in the specified order for clarity and consistency.
  $output = [ordered]@{
    CompanyName = $script:connectionOkta.CompanyName
    Domain      = $script:connectionOkta.Domain
    URI         = $script:connectionOkta.URI
    User        = $script:connectionOkta.User
    UserID      = $script:connectionOkta.UserID
  }

  # Add connection-specific details
  if ($script:connectionOkta.Tokens) {
    $output.ConnectionType = 'OAuth 2.0'

    # Attempt to get the friendly application name for a better user experience
    try {
      $app = Invoke-OktaAPI -Endpoint "apps/$($script:connectionOkta.ClientID)" -ErrorAction SilentlyContinue
      if ($app) {
        $output.ClientName = $app.label
      } else {
        # If the app name can't be retrieved, inform the user why.
        $output.ClientName = "<Permission 'okta.apps.read' is required to view name>"
      }
    }
    catch { Write-Verbose "Could not retrieve application name. The 'okta.apps.read' scope may be missing." }

    $output.ClientID = $script:connectionOkta.ClientID

    $allScopes = $script:connectionOkta.Tokens.scope -split ' '
    # Separate standard OIDC scopes from Okta-specific scopes for custom sorting.
    $standardScopes = $allScopes | Where-Object { $_ -notlike 'okta.*' } | Sort-Object
    $oktaScopes = $allScopes | Where-Object { $_ -like 'okta.*' } | Sort-Object

    # Always display standard scopes. Conditionally display Okta scopes based on the switch.
    $output.Scopes = (($standardScopes | ForEach-Object { "- $_" }) -join "`n")
    if ($IncludeOktaScopes) {
        if ($oktaScopes) {
            $output.OktaScopes = (($oktaScopes | ForEach-Object { "- $_" }) -join "`n")
        }
    } else {
        if ($oktaScopes) {
            $output.OktaScopes = "$($oktaScopes.Count) (use -IncludeOktaScopes to view)"
        }
    }
  }
  else {
    $output.ConnectionType = 'API Token (Legacy Auth)'
  }

  # Conditionally add the preview property at the end
  if ($script:connectionOkta.OktaPreview) {
    $output.OktaPreview = $true
  }

  # Return the final object. PowerShell's default list view will render the multi-line string nicely.
  [pscustomobject]$output
}