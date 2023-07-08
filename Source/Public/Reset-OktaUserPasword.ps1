function Reset-OktaUserPasword {
  [CmdletBinding()]
  param(
    #Okta User ID 
    [string]$Identity,
    #All user sessions are revoked except the current session.
    [switch]$RevokeSessions
  )
  $endPoint = switch ($RevokeSessions) {
    False {"users/$Identity/lifecycle/expire_password_with_temp_password"}
    True  {"users/$Identity/lifecycle/expire_password_with_temp_password?revokeSessions$($RevokeSessions.IsPresent)"}
  }
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = $endPoint

  try {
    Invoke-OktaAPI @oktaAPI -ErrorAction Stop
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}