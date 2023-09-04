function Get-OktaBehaviorRule {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param(
    [parameter(ParameterSetName='Default')]
    [string]$Identity,
    [ValidateSet('Velocity','Device','IP', 'Location')]
    [parameter(ParameterSetName='Type')]
    [string]$Type
  )
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.EndPoint = switch ($null -eq $identity) {
    True  {'behaviors'}
    False {"behaviors/$identity"}
  }

  $response = if ($type) {
    $filterType = switch ($type) {
      IP        {'Anomalous_IP'}
      Device    {'Anomalous_Device'}
      Location  {'Anomalous_Location'}
      Velocity  {'Velocity'}
    }
    (Invoke-OktaAPI @oktaAPI).where({$_.type -eq $filterType})
  }
  else {
    Invoke-OktaAPI @oktaAPI
  }
  $response | Select-Object -Property * -ExpandProperty Settings -ExcludeProperty Settings, _links
}