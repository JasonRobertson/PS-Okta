function Get-OktaDeviceAssurancePolicy {
  [cmdletbinding()]
  param(
    [string]$Identity
  )
  try {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Endpoint = "device-assurances/$identity"
    
    Invoke-OktaAPI @oktaAPI -ErrorAction Stop
  }
  catch {
    Write-Error $_.Exception.Message
  }
}