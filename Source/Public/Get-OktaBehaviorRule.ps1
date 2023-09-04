function Get-OktaBehaviorRule {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param(
    [parameter(ParameterSetName='Default')]
    [string]$Identity,
    [ValidateSet('Velocity','Device','IP', 'Location')]
    [parameter(ParameterSetName='Type')]
    [string]$Type
  )
  $filterType = switch ($type) {
    IP        {'Anomalous_IP'}
    Device    {'Anomalous_Device'}
    Location  {'Anomalous_Location'}
    Velocity  {'Velocity'}
  }
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.EndPoint = 'behaviors'
  
  $response = Invoke-OktaAPI @oktaAPI

  $filterResponse = switch ($PSCmdlet.ParameterSetName) {
    type    {$response.where({$_.type -eq $filterType})}
    default {
      if ($identity) {
        switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
          True  {$response.where({$_.name -like $Identity -or $_.ID -like $Identity})}
          False {$response.where({$_.name -eq $Identity -or $_.ID -eq $Identity})}
        }
      }
      else { $response }
    }
  }
  $filterResponse | Select-Object -Property * -ExpandProperty Settings -ExcludeProperty Settings, _links
}