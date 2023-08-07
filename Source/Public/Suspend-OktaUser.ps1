function Suspend-OktaUser {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Identity
  )
  $userID = (Get-OktaUser -Identity $identity -ErrorAction Stop).id

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = "users/$userID/lifecycle/suspend"

  Invoke-OktaAPI @oktaAPI 
}