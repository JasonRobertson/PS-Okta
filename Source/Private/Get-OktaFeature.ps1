function Get-OktaFeature {
  [cmdletbinding(DefaultParameterSetName='Default')]
  param(
    [parameter(ParameterSetName='Identity')]
    [string]$Identity,
    [ValidateSet('Enabled','Disabled')]
    [parameter(ParameterSetName='Default')]
    [string]$Status,
    [ValidateSet('EA','Beta')]
    [parameter(ParameterSetName='Default')]
    [string]$Stage
  )
  process {
    try {
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Endpoint = "features/$identity"

      $response = Invoke-OktaAPI @oktaAPI
      $response = if ($status){
        $response.where({$_.status -eq $status})
      }
      $response = if ($stage) {
         $response.where({$_.stage.value -eq $Stage}) 
      }
      foreach ($entry in $response) {
        $entry.stage = $entry.stage.value
        $entry | Select-Object -ExcludeProperty _links
      }
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}