function New-OktaBehaviorRule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory,Position=0)]
    [ValidateLength(1,128)]
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
          $velocity                  = [hashtable]::new()
          $velocity.Name             = 'VelocityKPH'
          $velocity.Type             = 'Int32'
          $velocity.Position         = 3
          $velocity.ValidateRange    = 1, 40075

          $dynamicParameters.Add([PSCustomObject]$velocity)
        }
        default {
          if ($type -eq 'Location') {
            $location                  = [hashtable]::new()
            $location.Name             = 'Granularity'
            $location.Type             = 'String'
            $location.Position         = 3
            $location.Mandatory        = $true
            $location.ValidateSet      = 'City', 'Country', 'Lat_Long', 'Subdivision'

            $dynamicParameters.Add([pscustomobject]$location)

            $radius               = [hashtable]::new()
            $radius.Name          = 'RadiusKilometers'
            $radius.Type          = 'int32'
            $radius.ValidateRange = 5, 1000
            $radius.Position      = 4

            $dynamicParameters.Add([pscustomobject]$radius)
          }

          $maxEvents                = [hashtable]::new()          
          $maxEvents.Name           = 'MaxEvents'
          $maxEvents.Type           = 'Int32'       
          $maxEvents.ValidateRange  = 1, 100
          $maxEvents.Position       = 5

          $dynamicParameters.Add([PSCustomObject]$maxEvents)

          $minEvents                = [hashtable]::new()          
          $minEvents.Name           = 'MinEvents'
          $minEvents.Type           = 'Int32'       
          $minEvents.ValidateRange  = 0, 10
          $minEvents.Position       = 6

          $dynamicParameters.Add([PSCustomObject]$minEvents)
        }
      }
      $dynamicParameters | New-DynamicParameter
    }
    process {
      $settings = [hashtable]::new()


      switch ($type) {
        Velocity {
          $settings.velocityKph = switch ($null -eq $PSBoundParameters['VelocityKPH']) {
            true  {805}
            false {$PSBoundParameters['VelocityKPH']}
          }
        }
        default {
          switch ($PSBoundParameters.Keys) {
            Granularity       {$settings.granularity                  = $PSBoundParameters['Granularity'].ToUpper()}
            MinEvents         {$settings.minEventsNeededForEvaluation = $PSBoundParameters['MinEvents']}
            MaxEvents         {$settings.maxEventsUsedForEvaluation   = $PSBoundParameters['MaxEvents']}
          }
          if ($PSBoundParameters['Granularity'] -eq 'Lat_Long') {
            $settings.radiusKilometers = switch ($nulle -eq $PSBoundParameters['RadiusKilometers']) {
              true {20}
              false {$PSBoundParameters['RadiusKilometers']}
            }
          }
        }
      }

      $global:oktaAPI         = [hashtable]::new()
      $oktaAPI.Body           = [hashtable]::new()
      $oktaAPI.Body.name      = $name
      $oktaAPI.Body.type      = switch ($type) {
                                  IP        {'ANOMALOUS_IP'}
                                  Device    {'ANOMALOUS_DEVICE'}
                                  Location  {'ANOMALOUS_LOCATION'}
                                  Velocity  {'VELOCITY'}
                                }
      $oktaAPI.Body.settings  = $settings
      $oktaAPI.Method         = 'POST'
      $oktaAPI.EndPoint       = 'behaviors'
      try {      
        (Invoke-OktaAPI @oktaAPI) | Select-Object -ExpandProperty Settings -Property * -ExcludeProperty Settings, _links
      }
      catch {
        Write-Error $_.Exception.Message
      }
    }
}