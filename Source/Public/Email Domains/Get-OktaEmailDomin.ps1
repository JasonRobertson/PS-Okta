function Get-OktaEmailDomain {
  <#
    .SYNOPSIS
    Retrieves information about Okta email domains.

    .DESCRIPTION
    This function interacts with the Okta API to fetch details about the email
    domains configured in your Okta organization. It's primarily used to list
    all email domains.

    .PARAMETER Identity
    This parameter is included for consistency with other `Get-Okta*` functions
    but is currently not utilized by the underlying Okta API for this endpoint.
    Providing a value for `Identity` will not filter the results.

    .EXAMPLE
    Get-OktaEmailDomain
    Retrieves a list of all configured Okta email domains.

    .NOTES
    This function relies on an external `Invoke-OktaAPI` function to handle the
    actual API calls and `Write-OktaError` for standardized error reporting.
    Ensure these functions are available in your PowerShell session.
  #>
  [cmdletbinding()]
  param(
    [parameter(Position=0)]
    [string]$Identity # This parameter is present for consistency but currently unused by the Okta API for this endpoint.
  )

  # Initialize a hashtable to configure the Okta API request.
  $oktaAPI = [hashtable]::new()

  # Construct the API endpoint based on whether an Identity is provided.
  if ($PSBoundParameters.ContainsKey('Identity') -and -not [string]::IsNullOrEmpty($Identity)) {
    # If Identity is provided, fetch the specific email domain.
    $oktaAPI.Endpoint = "email-domains/$Identity"
  }
  else {
    # If Identity is not provided, list all email domains.
    $oktaAPI.Endpoint = "email-domains"
  }

  # Attempt to invoke the Okta API.
  try {
    Invoke-OktaAPI @oktaAPI
  }
  # Catch any errors that occur during the API invocation.
  catch {
    # Utilize the custom error handling function Write-OktaError to format the exception message into a standardized Okta error object.
    $oktaError = Write-OktaError $PSItem.Exception.Message
    # Throw a terminating error, which stops the execution of the cmdlet and provides a clear error message to the user.
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
}