function Disconnect-Okta {
  try{
    if ($script:connectionOkta) {
      Remove-Variable connectionOkta -Scope Script -ErrorAction Stop
    }
    else {
      Write-Warning 'No Okta session found.'
    }
  }
  catch {
    Write-Error 'Failed to disconnect Okta session. Please close the terminal to forcefully close the session.'
  }
}