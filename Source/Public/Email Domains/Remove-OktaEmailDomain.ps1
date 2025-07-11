function Remove-OktaEmailDomain {
  <#
    .SYNOPSIS
    Removes an Okta email domain.

    .DESCRIPTION
    This function allows you to remove an existing custom email domain from
    your Okta organization. It requires the Identity of the email domain to
    be removed. The function will first attempt to resolve the full email
    domain ID from the provided identity.

    .PARAMETER Identity
    (Mandatory) The ID or name of the Okta email domain to be removed.
    This function will use Get-OktaEmailDomain to resolve the actual ID.

    .EXAMPLE
    # Remove an email domain by its ID
    Remove-OktaEmailDomain -Identity "eml1bjs08b3e3IuYf1d7"

    .EXAMPLE
    # Remove an email domain by its associated domain name
    Remove-OktaEmailDomain -Identity "example.com"

    .NOTES
    This function relies on external `Get-OktaEmailDomain`, `Invoke-OktaAPI`,
    and `Write-OktaError` functions. It handles errors by catching exceptions
    and `Write-OktaError` functions. Ensure these functions are available
    in your PowerShell session.
    Ensure you have the necessary permissions in Okta to delete email domains.
  #>
  [cmdletbinding()]
  param(
    [parameter(Mandatory, Position=0)]
    [string]$Identity
  )

  # Retrieve the ID of the email domain based on the provided Identity.
  # This assumes Get-OktaEmailDomain can handle both ID and name for lookup and returns an object with an 'id' property.
  $emailDomainID = (Get-OktaEmailDomain -Identity $Identity).id

  # Initialize a hashtable to configure the Okta API request for deletion.
  $oktaAPI = [hashtable]::new()
  $oktaAPI.Method = 'DELETE'
  $oktaAPI.Endpoint = "email-domains/$emaildomainID"

  # Attempt to invoke the Okta API to perform the deletion.
  try {
    Invoke-OktaAPI @oktaAPI
    # Add a success message (using Write-Verbose for less noisy output by default)
    Write-Verbose "Okta Email Domain '$Identity' removed successfully."
    # Output the result of the API call (Okta API DELETE usually returns 204 No Content, but Invoke-OktaAPI might return something else or nothing)
  }
  # Catch any errors that occur during the API invocation.
  catch {
    # If an error occurs, format the exception message using Write-OktaError,
    $oktaError = Write-OktaError $message
    # and then throw a terminating error.
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
}