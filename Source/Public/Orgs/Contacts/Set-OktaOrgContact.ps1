function Set-OktaOrgContact {
  [cmdletbinding()]
  param(
    [string]$Identity,
    [ValidateSet('Technical','Billing')]
    [parameter(Mandatory)]
    [string]$ContactType
  )
  try {
    $oktaAPI              = [hashtable]::new()
    $oktaAPI.Method       = 'PUT'
    $oktaAPI.Endpoint     = "org/contacts/$contactType"
    $oktaAPI.Body         = [hashtable]::new()
    $oktaAPI.Body.userId  = (Get-OktaUser -Identity $Identity).id

    Invoke-OktaAPI @oktaAPI | Out-Null
  }
  catch {
    Write-Error $_.Exception.Message
  }  
}