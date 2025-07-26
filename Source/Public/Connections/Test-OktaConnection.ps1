function Test-OktaConnection {
  [CmdletBinding()]
  param(
    [switch]$Quiet
  )
  #Verify the connection has been established
  if($null -eq $script:connectionOkta -or $null -eq $script:connectionOkta.URI) {
    Write-Host -ForegroundColor Red 'Connection to Okta has not been established.'
    Write-Host -ForegroundColor Yellow 'Run Connect-Okta to establish a session with Okta.'
    return $false
  }
  else {
    if (-not $Quiet) {
      Write-Host -ForegroundColor Green "Connection to $($script:connectionOkta.Domain) is active for user $($script:connectionOkta.User)."
    }
    return $true
  }
}