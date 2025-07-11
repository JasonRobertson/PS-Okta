function Disable-OktaDashboardFooter {
  <#
    .SYNOPSIS
    Disables (hides) the end-user footer on the Okta dashboard.

    .DESCRIPTION
    This function sends a request to the Okta API to hide the customizable
    footer that can be displayed on the end-user dashboard.
    It effectively sets the preference to not show this footer.

    .EXAMPLE
    Disable-OktaDashboardFooter

    # This command will attempt to hide the end-user footer.
    # If successful, the footer will no longer be visible to end users
    # on their Okta dashboard.

    .NOTES
    This function relies on the `Invoke-OktaAPI` function to communicate
    with the Okta API. Ensure this function is available in your session.
    You must have the necessary administrative permissions in your Okta
    organization to modify organization preferences.
    If an error occurs during the API call, it will be caught and displayed
    using `Write-Error`.
    To re-enable or show the footer, you would typically use corresponding
    function `Enable-OktaDashboardFooter` which calls a different API endpoint
    (e.g., 'org/preferences/showEndUserFooter').
  #>
  [cmdletbinding()]
  param()
  try {
    # Prepare the API request details
    $oktaApi = [hashtable]::new()
    $oktaApi.Method = 'POST'
    $oktaApi.EndPoint = 'org/preferences/hideEndUserFooter'
    # Call the Okta API
    Invoke-OktaAPI @oktaApi
  }
  catch {
    # Handle any errors during the API call
    Write-Error $PSItem.Exception.Message
  }
}