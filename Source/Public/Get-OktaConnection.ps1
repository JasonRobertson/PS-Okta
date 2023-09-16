function Get-OktaConnection {
  #Verify the connection has been established
  if($null -eq $connectionOkta.URI) {
    Write-Host -ForegroundColor Red 'Connection to Okta has not been established.'
    Write-Host -ForegroundColor Yellow 'Run Connect-Okta to establsih a session with Okta'
    break
  }
  else {
    $connectionOkta | Format-List Organization, User, ID
  }
}