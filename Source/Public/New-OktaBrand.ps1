function New-OktaBrand {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Name
  )
    $oktaAPI            = [hashtable]::new()
    $oktaAPI.Method     = 'POST'
    $oktaAPI.Endpoint   = 'brands'
    $oktaAPI.Body       = [hashtable]::new()
    $oktaAPI.Body.name  = $name
    Invoke-OktaAPI @oktaAPI | Select-Object -ExpandProperty defaultApp -ExcludeProperty _links, defaultApp
}