function Get-OktaConnection {
  #Verify the connection has been established
  if($connectionOkta.URI) {
    $connectionOkta | Select-Object -ExcludeProperty ApiToken
  }
  else {
    Write-Host -ForegroundColor Red 'Connection to Okta has not been established.'
    Write-Host -ForegroundColor Yellow 'Run Connect-Okta to establsih a session with Okta'
    break
  }
}