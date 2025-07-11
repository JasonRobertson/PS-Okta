function Disconnect-Okta {
  <#
    .SYNOPSIS
    Disconnects the current Okta API session.

    .DESCRIPTION
    This function removes the active Okta API connection variable from the
    script scope, effectively disconnecting your PowerShell session from Okta.
    If no active session is found, it issues a warning.

    .NOTES
    This function manages a script-scoped variable named `$script:connectionOkta`.
    It's designed to clean up the authentication token or session information
    established by a corresponding `Connect-Okta` function (not shown here).
    If a session cannot be gracefully disconnected, it suggests closing the
    terminal.
  #>
  try {
    # Check if the script-scoped variable '$script:connectionOkta' exists.
    # This variable is presumed to hold the active Okta session or connection
    # details.
    if ($script:connectionOkta) {
      # If the variable exists, remove it from the script scope.
      # '-Scope Script' ensures only the script-level variable is targeted.
      # '-ErrorAction Stop' will stop execution if the variable cannot be removed,
      # although in this context, it's unlikely to fail if it exists.
      Remove-Variable connectionOkta -Scope Script -ErrorAction Stop
      # You could add a success message here, e.g.:
      # Write-Host "Disconnected from Okta session."
    }
    else {
      # If the '$script:connectionOkta' variable is not found, it means there's
      # no active Okta session to disconnect. Issue a warning.
      Write-Warning 'No Okta session found.'
    }
  }
  catch {
    # If any error occurs during the disconnection attempt (e.g., issues with
    # Remove-Variable, though rare), catch it and provide an error message.
    # It also advises the user to close the terminal as a forceful method.
    Write-Error 'Failed to disconnect Okta session. Please close the terminal to forcefully close the session.'
  }
}