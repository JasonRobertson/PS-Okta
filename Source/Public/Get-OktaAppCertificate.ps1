function Get-OktaAppCertificate {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [parameter(ParameterSetName='KeyID')]
    [string]$Key
  )
  try {
    $appID = (Get-OktaApp -Identity $Identity).id
    if ($appID) {
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Endpoint = switch ($PSCmdlet.ParameterSetName) {
        KeyID   {"apps/$identity/credentials/keys/$key"}
        Default {"apps/$identity/credentials/keys"}
      }
      Invoke-OktaAPI @oktaAPI
    }
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}