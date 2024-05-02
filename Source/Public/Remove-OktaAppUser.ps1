function Remove-OktaAppUser {
  [cmdletbinding()]
  param(
    [parameter(Mandatory,postion=0)]
    [string]$Identity,
    [parameter(Mandatory,postion=1)]
    [string[]]$User,
    [switch]$SendEmail
  )
  begin {
    $appId = (Get-OktaApp -Identity $Identity).id
  }
  process {
    if ($appID) {
      try {
        foreach ($entry in $user) {
          $userID = (Get-OktaUser -Identity $entry).id
          if ($userID) {
            $oktaAPI          = [hashtable]::new()
            $oktaAPI.endpoint = "apps/$appID/users/$userID?$SendEmail"
            $oktaAPI.Method   = 'DELETE'
            Invoke-OktaAPI @oktaAPI
          }
        }
      }
      catch {
        Write-Error $PSItem.Exception.Message
      }
    }
  }
}