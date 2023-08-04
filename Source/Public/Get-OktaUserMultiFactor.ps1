function Get-OktaUserMultiFactor {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(Mandatory, ValueFromPipeline=$true, Position=0)]
    [alias('id')]
    [string[]]$Identity,
    [parameter(ParameterSetName='Status')]
    [ValidateSet('ACTIVE','DISABLED','ENROLLED','EXPIRED','INACTIVE','NOT_SETUP','PENDING_ACTIVATION')]
    $Status,
    [parameter(ParameterSetName='Provider')]
    [ValidateSet('CUSTOM','DUO','FIDO','GOOGLE','OKTA','RSA','SYMANTEC','YUBICO')]
    $Provider
  )
  foreach ($userID in $identity) {
    $id = (Invoke-OktaAPI -EndPoint users/$userID).id

    if ($id) {
      $apiResponse = Invoke-OktaAPI -EndPoint "users/$id/factors"
      switch ($pscmdlet.ParameterSetName) {
        Default  {$apiResponse}
        Status   {
          if ($apiResponse.Where({$_.Status -eq $status})) {
            $apiResponse.Where({$_.Status -eq $status})
          }
          else {
            Write-OktaError -Message "No Factor found with Status: '$status'"
          }
        }
        Provider {
          if ($apiResponse.Where({$_.Provider -eq $Provider})) {
            $apiResponse.Where({$_.Provider -eq $Provider})
          }
          else {
            Write-OktaError -Message "No Factor found with Provider: '$provider'"
          }
        }
      }
    }
  }
}