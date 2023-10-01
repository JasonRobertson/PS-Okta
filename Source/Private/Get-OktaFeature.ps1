function Get-OktaFeature {
  [cmdletbinding(DefaultParameterSetName='List')]
  param(
    [parameter(Mandatory,ParameterSetName='Identity', Position='0')]
    [string]$Identity,
    [ValidateSet('Enabled','Disabled')]
    [parameter(ParameterSetName='List',Position='0')]
    [string]$Status,
    [ValidateSet('EA','Beta')]
    [parameter(ParameterSetName='List',Position='1')]
    [string]$Stage
  )
  process {
    try {
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Endpoint = "features/$identity"
      Write-Debug $oktaAPI.Endpoint
      $response = foreach ($entry in (Invoke-OktaAPI @oktaAPI) ) {
        $entry.stage = $entry.stage.value
        $entry 
      }
      if ($status){
        $response = $response.Where({$_.Status -eq $status})
      }
      if ($Stage) {
        $response = $response.Where({$_.Stage -eq $stage})
      }
      return $response
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}