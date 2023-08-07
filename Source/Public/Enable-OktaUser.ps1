function Enable-OktaUser {
  [CmdletBinding(DefaultParameterSetName='UserID')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(ParameterSetName='UserID')]
    [string]$Identity,
    [switch]$SendEmail
  )
  $oktaUser = Get-OktaUser -Identity $Identity -ErrorAction Stop
  $userID = $oktaUser.ID
  
  if (($oktaUser).status -eq 'PROVISIONED') {
    Write-Warning "$identity is already activated"
  }
  else {
    $endPoint = switch ($oktaUser.Status) {
      Default   {"users/$userID/lifecycle/activate?sendEmail=$sendEmail"}
      SUSPENDED {"users/$userID/lifecycle/unsuspend"}
    }

    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = $endPoint
    
    Invoke-OktaAPI @oktaAPI
    Write-Host -ForegroundColor Green -Object "Successfully enabled $identity"
  }
}