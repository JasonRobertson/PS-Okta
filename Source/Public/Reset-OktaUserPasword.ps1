function Reset-OktaUserPassword {
  [CmdletBinding()]
  param(
    #Okta User ID 
    [string]$Identity,
    #All user sessions are revoked except the current session.
    [switch]$RevokeSessions,
    [switch]$SendEmail
  )
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = "users/$Identity/lifecycle/expire_password_with_temp_password?revokeSessions=$($RevokeSessions.IsPresent)&sendEmail=$($SendEmail.IsPresent)"

  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}