function Remove-OktaDeviceAssurancePolicy {
  [cmdletbinding()]
  param(
    [string]$Identity
  )
  try {
    $deviceAssuranceId = (Get-OktaDeviceAssurancePolicy -Identity $Identity).id
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Endpoint = "device-assurances/$deviceAssuranceID"
    
    Invoke-OktaAPI @oktaAPI -ErrorAction Stop
  }
  catch {
    Write-Error $_.Exception.Message
  }
}