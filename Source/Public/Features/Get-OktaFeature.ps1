<#
.SYNOPSIS
  Retrieves a list of features and their status for your Okta organization.
.DESCRIPTION
  This function queries the Okta Features API to list all available features, their status (ENABLED/DISABLED), and their stage (EA/BETA/GA).
  This is useful for programmatically determining which Okta products (like Identity Governance) are enabled in your tenant before attempting to use their associated APIs or scopes.
.PARAMETER Identity
  The name or ID of a specific feature to retrieve. Wildcards (*) are supported for pattern matching. If omitted, all features are returned.
.EXAMPLE
  PS C:\> Get-OktaFeature

  id                                      name                                    status
  --                                      ----                                    ------
  okta_identity_governance                Okta Identity Governance                ENABLED
  reports_password_health                 Password Health Report                  ENABLED
  custom_url_domain                       Custom URL Domain                       ENABLED
  ...

  Lists all features available in the Okta organization and their current status.
.EXAMPLE
  PS C:\> Get-OktaFeature -Identity '*governance*'

  id                                      name                                    status
  --                                      ----                                    ------
  okta_identity_governance                Okta Identity Governance                ENABLED

  Finds a specific feature by name, in this case, checking if Okta Identity Governance (OIG) is enabled.
.NOTES
  Requires an API connection with at least 'okta.features.read' permission, which is included in the 'Read-only Administrator' role.
#>
function Get-OktaFeature {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Position = 0, ValueFromPipelineByPropertyName)]
        [string]$Identity
    )

    try {
        Write-Verbose "Retrieving all features from the Okta API..."
        $features = Invoke-OktaAPI -Endpoint 'features'

        if ($PSBoundParameters.ContainsKey('Identity')) {
            Write-Verbose "Filtering features with Identity: $Identity"
            $features | Where-Object { $_.name -like $Identity -or $_.id -like $Identity }
        }
        else {
            $features
        }
    }
    catch {
        $errorMessage = "Failed to retrieve Okta features. Ensure your API Token has sufficient permissions (e.g., Read-only Administrator)."
        $oktaError = $_.ErrorDetails.Message | ConvertFrom-Json -ErrorAction SilentlyContinue
        if ($oktaError -and $oktaError.errorSummary) {
            $errorMessage += " Okta API Error: $($oktaError.errorSummary)"
        }
        else {
            $errorMessage += " Exception: $($_.Exception.Message)"
        }
        $newErrorRecord = [System.Management.Automation.ErrorRecord]::new($_.Exception, "FeatureRetrievalFailure", [System.Management.Automation.ErrorCategory]::ReadError, $null)
        $newErrorRecord.ErrorDetails = [System.Management.Automation.ErrorDetails]::new($errorMessage)
        $PSCmdlet.ThrowTerminatingError($newErrorRecord)
    }
}