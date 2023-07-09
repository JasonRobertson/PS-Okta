function Get-OktaUserFactor {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(Mandatory, ValueFromPipeline=$true, Position=0)]
    [alias('id')]
    [string[]]$Identity,
    [ValidateSet('ACTIVE','DISABLED','ENROLLED','EXPIRED','INACTIVE','NOT_SETUP','PENDING_ACTIVATION')]
    $Status,
    [ValidateSet('CUSTOM','DUO','FIDO','GOOGLE','OKTA','RSA','SYMANTEC','YUBICO')]
    $Provider
  )
  foreach ($userID in $identity) {
    $id = (Invoke-OktaAPI -EndPoint users/$userID).id
    $apiResponse = Invoke-OktaAPI -EndPoint "users/$id/factors"
    
    if ($Provider -and $Status) {
      $apiResponse.Where({$_.Provider -eq $Provider -and $_.Status -eq $status})
    }
    elseif ($status){ 
      $apiResponse.Where({$_.Status -eq $status})
    }
    elseif ($Provider) {
      $apiResponse.Where({$_.Provider -eq $Provider})
    }
    else {
      $apiResponse
    }
  }
}