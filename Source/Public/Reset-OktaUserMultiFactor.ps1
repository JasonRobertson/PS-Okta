
function Reset-OktaUserMultiFactor {
  [CmdletBinding(DefaultParameterSetName='Reset')]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [parameter(Mandatory, ParameterSetName='Provider')]
    [ValidateSet('CUSTOM','DUO','FIDO','GOOGLE','OKTA','RSA','SYMANTEC','YUBICO')]
    [string]$Provider,
    [parameter(ParameterSetName='Provider')]
    [switch]$RemoveRecoveryEnrollment = $false,
    [parameter(ParameterSetName='Reset')]
    [switch]$All
  )
  $oktaUserId = (Get-OktaUser -Identity $Identity).id
  switch ($PSCmdlet.ParameterSetName) {
    Reset    {
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Method   = 'POST'
      $oktaAPI.Endpoint = "/users/$oktaUserID/lifecycle/reset_factors"
    }
    Provider {
      $factorID = (Get-OktaUserMultiFactor -Identity $oktaUserID -Provider $Provider -ErrorAction STOP).id

      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Method   = 'Delete'
      $oktaAPI.Endpoint = -join ("/users/$oktaUserID/factors/$factorID","?removeRecoveryEnrollment=$RemoveRecoveryEnrollment")
    }
  }
  Write-Debug "EndPoint: $endPoint"
  Invoke-OktaAPI @oktaAPI
}
