function Enable-OktaUser {
  [CmdletBinding(DefaultParameterSetName='UserID')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(ParameterSetName='UserID')]
    [string]$Identity,
    [switch]$SendEmail
  )
  $oktaAPI                = [hashtable]::new()
  $oktaAPI.All            = $all
  $oktaAPI.Method         = 'POST'
  $oktaAPI.Body           = [hashtable]::new()
  $oktaAPI.Body.sendEmail = $SendEmail

  $oktaAPI.Endpoint = "users/$oktaUserID/lifecycle/activate"

  Invoke-OktaAPI @oktaAPI
}