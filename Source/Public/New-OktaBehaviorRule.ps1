function New-OktaBehaviorRule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory,Position=0)]
    [string]$Name,
    [ValidateSet('Active','Inactive')]
    [parameter(Position=1)]
    [string]$Status,
    [ValidateSet('Velocity','Device', 'IP', 'Location')]
    [parameter(Mandatory,Position=2)]
    [string]$Type
  )
    dynamicparam {
      $dynamicParameters = {}.invoke()
      switch -wildcard ($type) {
        Velocity {
          $velocityKPH               = [hashtable]::new()
          $velocityKPH.Name          = 'VelocityKPH'
          $velocityKPH.Type          = 'Int32'
          $velocityKPH.ValidateRange = 1, 40075
          $velocityKPH.Position      = 3
          $velocityKPH.DefaultValue  = 20

          $dynamicParameters.Add([PSCustomObject]$velocityKPH)
        }
        default {
          $maxEvents                = [hashtable]::new()          
          $maxEvents.Name           = 'MaxEvents'
          $maxEvents.Type           = 'Int32'       
          $maxEvents.ValidateRange  = 1, 100
          $maxEvents.Position       = 3

          $dynamicParameters.Add([PSCustomObject]$maxEvents)

          $minEvents                = [hashtable]::new()          
          $minEvents.Name           = 'MinEvents'
          $minEvents.Type           = 'Int32'       
          $minEvents.ValidateRange  = 0, 10
          $minEvents.Position       = 3

          $dynamicParameters.Add([PSCustomObject]$minEvents)

          if ($type -eq 'Location') {
            $granularity              = [hashtable]::new()
            $granularity.Name         = 'Granularity'
            $granularity.Type         = 'String'
            $granularity.ValidateSet  = 'City', 'County', 'Lat_Long', 'Subdivision'
            $granularity.Position     = 4

            $dynamicParameters.Add([pscustomobject]$granularity)

            $radiusKilometers               = [hashtable]::new()
            $radiusKilometers.Name          = 'RadiusKilometers'
            $radiusKilometers.Type          = 'int32'
            $radiusKilometers.ValidateRange = 1, 1000
            $radiusKilometers.Position      = 5
            $radiusKilometers.DefaultValue  = 20

            $dynamicParameters.Add([pscustomobject]$radiusKilometers)
          }
        }
      }
      $dynamicParameters | New-DynamicParameter
    }
    process {
      $settings = [hashtable]::new()
      switch ($type) {
        Velocity {
          $settings.velocityKph = if ($PSBoundParameters['VelocityKPH']) {
            $PSBoundParameters['VelocityKPH']
          } 
          else {
            805
          }
        }
        default {
          if ($type -eq 'Location') {
            $settings.granularity       = ($PSBoundParameters['Granularity']).ToUpper()
            if ($PSBoundParameters['Granularity'] -eq 'Lat_Long') {
              $settings.radiusKilometers  = if ($PSBoundParameters['RadiusKilometers']) {$PSBoundParameters['RadiusKilometers']} else {20}
            }
          }
          $settings.maxEventsUsedForEvaluation = if ($PSBoundParameters['MaxEvents']) {$PSBoundParameters['MaxEvents']} else {20}
          $settings.minEventsUsedForEvaluation = if ($PSBoundParameters['MinEvents']) {$PSBoundParameters['MinEvents']} else {0}
        }
      }
      $global:oktaAPI         = [hashtable]::new()
      $oktaAPI.Body           = [hashtable]::new()
      $oktaAPI.Body.name      = $PSBoundParameters['Name']
      $oktaAPI.Body.type      = switch ($type) {
                                  IP        {'ANOMALOUS_IP'}
                                  Device    {'ANOMALOUS_DEVICE'}
                                  Location  {'ANOMALOUS_LOCATION'}
                                  Velocity  {'VELOCITY'}
                                }
      $oktaAPI.Body.settings  = $settings
      $oktaAPI.Method         = 'POST'
      $oktaAPI.EndPoint       = 'behaviors'
      (Invoke-OktaAPI @oktaAPI) | Select-Object -ExpandProperty Settings -Property * -ExcludeProperty Settings, _links
    }
}