function Get-OktaBrand {
  <#
    .SYNOPSIS
    Retrieves detailed Okta brand configurations and properties.

    .DESCRIPTION
    This function interacts with the Okta API to fetch information about Okta
    brands. It can retrieve a specific brand by its unique **ID** or through
    a partial or full **name match**. Alternatively, you can list multiple
    brands by specifying a **limit** on the number of results. The function
    handles API communication and error reporting, returning a refined dataset
    focused on the `defaultApp` properties of the retrieved brands, while
    excluding extraneous metadata for a cleaner output.

    .PARAMETER Identity
    Specifies the **ID** (e.g., `0oa786gznlVSf15sC5d7`) or **name** (e.g.,
    `dev-56213942_default`) of the Okta brand to retrieve. If an ID is
    provided, it attempts an exact match. If a name is provided, it performs a
    case-insensitive wildcard search. If this parameter is omitted, the
    function retrieves a list of all brands up to the specified `Limit`.

    .PARAMETER Limit
    Defines the **maximum number of Okta brands** to return when no `Identity`
    is specified or when multiple brands match a partial name search. The
    acceptable range for this value is **1 to 1000**. The default value is
    **200**, which provides a reasonable number of results without causing
    excessively large API responses.

    .EXAMPLE
    # Retrieve a specific Okta brand by its unique ID
    Get-OktaBrand -Identity "0oa786gznlVSf15sC5d7"

    .EXAMPLE
    # Search for Okta brands with names containing "dev"
    Get-OktaBrand -Identity "dev"

    .EXAMPLE
    # Get the first 20 Okta brands when no specific identity is provided
    Get-OktaBrand -Limit 20

    .NOTES
    This function relies on external `Invoke-OktaAPI` and `Write-OktaError`
    functions for API calls and standardized error reporting, respectively.
    Ensure these functions are available in your PowerShell session. The
    `defaultApp` property is expanded, and both the `_links` and `defaultApp`
    properties themselves are excluded from the final output for clarity.
  #>
  [CmdletBinding()]
  param(
    [string]$Identity,
    [ValidateRange(1,1000)]
    [int32]$Limit = 200
  )

  # Initialize a hashtable to configure the Okta API request, holding
  # parameters such as the request body and endpoint.
  $oktaAPI = [hashtable]::new()
  # Create a nested hashtable for the API request body, where parameters
  # specific to the API endpoint's payload will reside.
  $oktaAPI.Body = [hashtable]::new()
  # Set the 'limit' parameter within the API request body, controlling the
  # maximum number of results the Okta API should return.
  $oktaAPI.Body.limit = $Limit
  # Define the specific API endpoint to target, which is the 'brands' endpoint.
  $oktaAPI.Endpoint = 'brands'

  # Determine whether to search for a specific identity or to list all brands.
  $response = if ($identity) {
    # If an Identity is provided, invoke the Okta API and then filter the results. The .where() method selects objects where the 'Id' property
    # exactly matches the provided identity OR the 'name' property contains the provided identity (case-insensitive wildcard match).
    (Invoke-OktaAPI @oktaAPI).where({$_.Id -eq $identity -or $_.name -like "*$identity*"})
  }
  else {
    # If no Identity is provided, simply invoke the Okta API to retrieve all brands up to the specified $Limit.
    Invoke-OktaAPI @oktaAPI
  }

  # Check if the API call returned any response.
  if (-not $response) {
    # If the response is null or empty, it indicates a failure to retrieve the # brand(s). Construct a detailed error message to guide the user on
    # potential issues and provide examples.
    $message = {
      "Failed to retrieve Okta Brand '$identity'. Please verify the Identity `
      matches one of the following examples:"
      'ID:   0oa786gznlVSf15sC5d7'
      'Name: dev-56213942_default'
    }.invoke() | Out-String # Convert the script block output to a single string.

    # Utilize a custom error handling function to create a standardized Okta
    # error object.
    $oktaError = Write-OktaError $message
    # Throw a terminating error, which stops the execution of the cmdlet and
    # provides a clear error message to the user.
    $pscmdlet.ThrowTerminatingError($oktaError)
  }
  else {
    # If a successful response is received, process and return the relevant data. Select the 'defaultApp' property and expand it, effectively
    # flattening the output to show the properties directly within
    # 'defaultApp'. Exclude the '_links' property (often API metadata) and
    # the original 'defaultApp' property itself to provide a cleaner, focused
    # output of just the expanded properties.
    return $response | Select-Object -ExpandProperty defaultApp -ExcludeProperty _links, defaultApp
  }
}