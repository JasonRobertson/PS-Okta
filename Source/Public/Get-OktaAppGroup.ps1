function Get-OktaAppGroup {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [string]$Group,
    [ValidateRange(1,500)]
    [int]$Limit=500,
    [switch]$all
  )
  $appID = (Get-OktaApp -Identity $Identity).id
  if ($appID) {
    if ($group) { 
      $groupID = (Get-OktaGroup -Identity $group).id 
      if ($groupID -gt 1) {
        
      }
    }
    $endpoint = switch ($null -eq $GroupID ) {
      true  {"/apps/$appID/groups"}
      false {"/apps/$appID/groups/$groupID"}
    }
    $oktaAPI            = [hashtable]::new()
    $oktaAPI.All        = $all
    $oktaAPI.Body       = [hashtable]::new()
    $oktaAPI.Body.limit = $limit
    $oktaAPI.Endpoint   = $endpoint
    
    (Invoke-OktaAPI @oktaAPI) | Select-Object -ExpandProperty profile -Property * -ExcludeProperty Profile,_links
  }
}