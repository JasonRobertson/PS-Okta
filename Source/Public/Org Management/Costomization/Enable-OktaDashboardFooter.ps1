function Enable-OktaDashboardFooter {
  <#
    .SYNOPSIS
    Enables (shows) the end-user footer on the Okta dashboard.

    .DESCRIPTION
    This function sends a request to the Okta API to show the customizable
    footer that can be displayed on the end-user dashboard.
    It effectively sets the preference to display this footer.

    .EXAMPLE
    Enable-OktaDashboardFooter

    # This command will attempt to show the end-user footer.
    # If successful, the footer will become visible to end users
    # on their Okta dashboard (assuming it has been configured with content).

    .NOTES
    This function relies on the `Invoke-OktaAPI` function to communicate
    with the Okta API. Ensure this function is available in your session.
    You must have the necessary administrative permissions in your Okta
    organization to modify organization preferences.
    If an error occurs during the API call, it will be caught and displayed
    using `Write-OktaError`.
    To hide the footer, you would typically use a corresponding
    function like `Disable-OktaDashboardFooter` which calls a different API endpoint
    (e.g., 'org/preferences/hideEndUserFooter').
  #>
  [cmdletbinding()]
  param()
  try {
    # Prepare the API request details
    $oktaApi = [hashtable]::new()
    $oktaApi.Method = 'POST'
    $oktaApi.EndPoint = 'org/preferences/showEndUserFooter'
    # Call the Okta API
    Invoke-OktaAPI @oktaApi
  }
  catch {
    # Handle any errors during the API call
    Write-OktaError $PSItem.Exception.Message
  }
}