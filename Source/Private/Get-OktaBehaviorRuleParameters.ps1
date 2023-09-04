function Get-OktaBehaviorRuleParameters {
  $dynamicParameters = {}.invoke()
  switch -wildcard ($type) {
    Velocity {
      $velocityKPH               = [hashtable]::new()
      $velocityKPH.Name          = 'VelocityKPH'
      $velocityKPH.Type          = 'Int32'
      $velocityKPH.ValidateRange = 1, 40075
      $velocityKPH.Position      = 3
      $velocityKPH.DefaultValue  = 805

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