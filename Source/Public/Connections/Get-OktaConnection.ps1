function Get-OktaConnection {
  #Verify the connection has been established
  if($script:connectionOkta.URI) {
    $script:connectionOkta | Select-Object -ExcludeProperty ApiToken, Tokens
  }
  else {
    Write-Host -ForegroundColor Red 'Connection to Okta has not been established.'
    Write-Host -ForegroundColor Yellow 'Run Connect-Okta to establsih a session with Okta'
    return
  }
}