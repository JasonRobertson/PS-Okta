function Get-OktaAppGroup {
  [CmdletBinding(DefaultParameterSetName='Limit')]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [ValidateRange(1,500)]
    [int]$Limit=500,
    [switch]$all
  )
  $appID = (Get-OktaApp -Identity $Identity).id

  if ($appID) {
    $oktaAPI            = [hashtable]::new()
    $oktaAPI.All        = $all
    $oktaAPI.Body       = [hashtable]::new()
    $oktaAPI.Body.limit = $limit
    $oktaAPI.Endpoint   = "/apps/$appID/groups"

    Invoke-OktaAPI @oktaAPI
  }
}