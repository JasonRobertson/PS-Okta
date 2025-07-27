<#
.SYNOPSIS
  Retrieves the list of granted API scopes for a specific OIDC application.
.DESCRIPTION
  This function queries the Okta API to find all the API scopes (permissions) that have been explicitly granted
  to an OIDC application, identified by its ClientID. This is useful for auditing and verifying application permissions.
.PARAMETER ClientID
  The Client ID of the OIDC application for which to retrieve the granted scopes.
.EXAMPLE
  PS C:\> Get-OktaApplicationScope -ClientID '0oatm6vk9rTIDc272697'

  okta.apps.read
  okta.orgs.read
  okta.users.read.self

  Retrieves and displays a sorted list of all API scopes granted to the specified application.
.OUTPUTS
  [string[]] - An array of strings, where each string is a granted API scope.
.NOTES
  This function requires the 'okta.apps.read' scope to be granted to the currently connected session's application
  in order to read the grants of other applications.
#>
function Get-OktaApplicationScope {
    [CmdletBinding()]
    [OutputType([string[]])]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [string]$ClientID
    )

    process {
        try {
            Write-Verbose "Fetching API scope grants for ClientID: $ClientID"
            $grants = Invoke-OktaAPI -Endpoint "apps/$ClientID/grants"
            return $grants | ForEach-Object { $_.scopeId } | Sort-Object
        }
        catch {
            $errorMessage = "Failed to retrieve scopes for ClientID '$ClientID'. Ensure the current session has the 'okta.apps.read' permission. Original error: $_"
            $PSCmdlet.ThrowTerminatingError($_)
        }
    }
}