function Set-OktaDomain {
  [cmdletbinding()]
  param(
    [parameter(Mandatory,ValueFromPipeline, Position=0)]
    [string[]]$Identity,
    [parameter(Mandatory, Position=1)]
    [string]$BrandID
  )
  process {
    try {
      $oktaAPI              = [hashtable]::new()
      $oktaAPI.Body         = [hashtable]::new()
      $oktaAPI.Body.brandId = $BrandID
      $oktaAPI.Method       = 'PUT'
      $oktaAPI.Endpoint     = "domains/$Identity"
      Invoke-OktaAPI @oktaAPI | Select-Object -ExcludeProperty _links
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}