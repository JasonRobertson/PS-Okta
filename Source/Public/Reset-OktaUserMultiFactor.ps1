
function Reset-OktaUserMultiFactor {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [parameter(Mandatory, ParameterSetName='Provider')]
    [ValidateSet('CUSTOM','DUO','FIDO','GOOGLE','OKTA','RSA','SYMANTEC','YUBICO')]
    [string]$Provider,
    [parameter(ParameterSetName='Provider')]
    [switch]$RemoveRecoveryEnrollment,
    [parameter(ParameterSetName='Default')]
    [switch]$All
  )
  $factorID = if ($provider) {(Get-OktaUserMultiFactor -Identity $Identity -Provider $Provider).id}
  $endPoint = switch ($PSCmdlet.ParameterSetName) {
    Default  {"/users/$identity/lifecycle/reset_factors"}
    Provider {"/users/$identity/factors/$factorID?removeRecoveryEnrollment=$RemoveRecoveryEnrollment"}
  }
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = $endPoint

  Invoke-OktaAPI @oktaAPI
}
