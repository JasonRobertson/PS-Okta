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
      $response = switch ($pscmdlet.ParameterSetName) {
        Status   {$apiResponse.Where({$_.Status -eq $status})}
        Provider {$apiResponse.Where({$_.Provider -eq $Provider})}
        Default  {$apiResponse}
      }
      switch ($null -ne $response) {
        True  {$response}
        False {
          $message = switch ($pscmdlet.ParameterSetName) {
            Status   {"No Factor found with Status: '$status'"}
            Provider {"No Factor found with Provider: '$provider'"}
          }
          Write-OktaError -Message $message
        }
      }
    }
  }
}