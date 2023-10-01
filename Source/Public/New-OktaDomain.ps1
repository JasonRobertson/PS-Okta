function New-OktaDomain {
  [cmdletbinding()]
  param(
    [parameter(Mandatory,Position=0)]
    [string]$Name,
    [ValidateSet('Manual', 'Okta Managed')]
    $CertificateSourceType = 'Okta Managed'
  )
  try {
    $certificateSourceType = $certificateSourceType.Replace(' ','_').ToUpper()

    $oktaAPI                            = [hashtable]::new()
    $oktaAPI.Body                       = [hashtable]::new()
    $oktaAPI.Body.domain                = $name
    $oktaAPI.Body.certificateSourceType = $certificateSourceType
    $oktaAPI.Method                     = 'POST'
    $oktaAPI.Endpoint                   = 'domains'
    
    Invoke-OktaAPI @oktaAPI 
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}