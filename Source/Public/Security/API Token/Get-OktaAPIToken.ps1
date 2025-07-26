<#
.SYNOPSIS
  Retrieves Okta API tokens for the currently authenticated user.
.DESCRIPTION
  This function retrieves API tokens from the Okta organization that belong to the user associated with the current API Token connection.
  It can retrieve a specific token by its ID, search for tokens by name, or list all tokens for the user.
.PARAMETER Identity
  The ID or name of the API token to retrieve. Wildcards (*) are supported for name searches. If omitted, all tokens for the current user are returned.
.EXAMPLE
  # First, connect with an API Token. Note that OAuth connections cannot manage API tokens.
  PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
  PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
  PS C:\> Get-OktaAPIToken

  Retrieves all API tokens belonging to the authenticated user.
.EXAMPLE
  PS C:\> Get-OktaAPIToken -Identity '0oabc...'

  Retrieves a single API token by its unique ID.
.EXAMPLE
  PS C:\> Get-OktaAPIToken -Identity '*service*'

  Searches for all API tokens belonging to the current user that have 'service' in their name.
.NOTES
  This command requires an active Okta connection using a legacy API Token. It cannot be used with an OAuth 2.0 connection.
  The API token used for the connection must have permissions to read its own tokens. A '403 Forbidden' error can occur if this is not the case, though this is rare.
#>
function Get-OktaAPIToken {
  [CmdletBinding()]
  [OutputType([pscustomobject])]
  param (
    [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
    [string]$Identity
  )

  try {
    # API tokens are always owned by a user, so we query the tokens for the current user.
    $endpoint = "users/me/tokens"
    Write-Verbose "Retrieving API tokens from endpoint: $endpoint"
    $tokens = Invoke-OktaAPI -Endpoint $endpoint

    if ($PSBoundParameters.ContainsKey('Identity')) {
      Write-Verbose "Filtering tokens with Identity: $Identity"
      $tokens | Where-Object { $_.id -eq $Identity -or $_.name -like $Identity }
    }
    else {
      $tokens
    }
  }
  catch {
    $errorMessage = "Failed to retrieve Okta API tokens. Ensure you are connected with a valid API Token."
    $oktaError = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
    if ($oktaError -and $oktaError.errorSummary) {
      $errorMessage += " Okta API Error: $($oktaError.errorSummary)"
    }
    $newErrorRecord = [System.Management.Automation.ErrorRecord]::new($_.Exception, "ApiTokenRetrievalFailure", [System.Management.Automation.ErrorCategory]::ReadError, $null)
    $newErrorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($errorMessage)
    $PSCmdlet.ThrowTerminatingError($newErrorRecord)
  }
}