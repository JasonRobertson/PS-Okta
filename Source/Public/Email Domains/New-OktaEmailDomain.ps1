function New-OktaEmailDomain {
  <#
    .SYNOPSIS
    Creates a new custom email domain in Okta.

    .DESCRIPTION
    This function allows you to configure a new custom email domain within your
    Okta organization. It requires details such as the domain name, a display
    name, the associated Okta brand ID, a username for validation, and an
    optional validation subdomain. The function performs a lookup for the
    Brand ID to ensure its validity before attempting to create the email
    domain.

    .PARAMETER Domain
    (Mandatory) Specifies the actual domain name you wish to add, e.g.,
    `example.com`. This will be the domain used for sending emails from Okta.

    .PARAMETER DisplayName
    (Mandatory) A user-friendly name for the email domain that will be
    displayed in the Okta Admin Console.

    .PARAMETER BrandId
    (Mandatory) The ID or name of the Okta brand to which this email domain
    will be associated. This function will internally resolve the actual
    Brand ID using `Get-OktaBrand`.

    .PARAMETER Username
    (Mandatory) The username associated with the email domain for validation
    purposes. This is typically an email address within the domain.

    .PARAMETER ValidationSubdomain
    (Optional) The subdomain used for email domain validation. The default
    value is 'mail'. This is typically used for DNS CNAME records required
    by Okta for domain verification.

    .EXAMPLE
    # Create a new email domain for 'example.com' associated with a brand
    # named 'MyCompany_Default'
    New-OktaEmailDomain -Domain "example.com" -DisplayName "Example Company Emails" -BrandId "MyCompany_Default" -Username "admin@example.com"

    .EXAMPLE
    # Create a new email domain with a custom validation subdomain
    New-OktaEmailDomain -Domain "test.org" -DisplayName "Test Org Emails" -BrandId "0oa123abc456def7890" -Username "support@test.org" -ValidationSubdomain "oktavalidate"

    .NOTES
    This function relies on external Invoke-OktaAPI and Get-OktaBrand
    functions for API calls and brand lookup, respectively. It also uses
    Write-OktaError for standardized error reporting. Ensure these functions
    are available in your PowerShell session.
  #>
  [cmdletbinding()]
  param(
    [parameter(Position=0,Mandatory)]
    [string]$Domain,
    [parameter(Position=1,Mandatory)]
    [string]$DisplayName,
    [parameter(Position=2,Mandatory)]
    [string]$BrandId,
    [parameter(Position=3, Mandatory)]
    [string]$Username,
    [parameter(Position=4)]
    [string]$ValidationSubdomain = 'mail'
  )

  # Initialize a hashtable to construct the request body for the Okta API call.
  $body = [hashtable]::new()
  # Set the 'domain' property in the request body from the function parameter.
  $body.domain = $Domain
  # Resolve the BrandId from the provided BrandId parameter using Get-OktaBrand.
  # This ensures we get the actual Okta Brand ID, whether the user provided an
  # ID or a name.
  $body.brandId = (Get-OktaBrand -Identity $BrandId).id
  # Set the 'displayName' property in the request body.
  $body.displayName = $DisplayName
  # Set the 'userName' property in the request body for validation.
  $body.userName = $Username
  # Set the 'validationSubdomain' property, using the default if not provided.
  $body.validationSubdomain = $ValidationSubdomain

  # Initialize a hashtable for the overall Okta API request configuration.
  $oktaAPI = [hashtable]::new()
  # Assign the constructed request body to the 'Body' property of the API config.
  $oktaAPI.Body = $body
  # Specify the HTTP method for the API call, which is 'POST' for creation.
  $oktaAPI.Method = 'POST'
  # Set the API endpoint to 'email-domains' for creating a new email domain.
  $oktaAPI.Endpoint = 'email-domains'

  # Check if a valid BrandId was successfully resolved from the Get-OktaBrand call.
  if ($body.brandId) {
    # If the BrandId is valid, proceed to invoke the Okta API to create the new email domain.
    Invoke-OktaAPI @oktaAPI
  }
  else {
    # If Get-OktaBrand returned no results for the provided BrandId, construct  an informative error message for the user.
    $message = {
      "The Okta Brand '$BrandId' returned no results."
      "Run Get-OktaBrand to verify the id/name of the Okta brand you want to `
      configure a custom email domain for."
    }.invoke() # Invoke the script block to get the multi-line message.
    # Use the custom error writing function to format and display the error.
    $oktaError = Write-OktaError $message
    # Note: The original code had the ThrowTerminatingError commented out.
    # To make this a terminating error that stops execution, uncomment the
    # line below.
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
}