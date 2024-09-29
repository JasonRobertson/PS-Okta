function Set-OktaBehaviorRule {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory,Position=0)]
    [string]$Identity,
    [Parameter(Position=1)]
    [ValidateLength(1,128)]
    [string]$Name,
    [ValidateSet('Velocity','Device', 'IP', 'Location')]
    [parameter(Position=2)]
    [string]$Type
  )
  dynamicparam {
    Get-OktaBehaviorRuleParameters
  }
  process {
    if ([wildcardpattern]::ContainsWildcardCharacters($identity)){
      $message = {
        'Wildcard is not supported; verify the identity matches one of the examples:'
        'ID:   0oa786gznlVSf15sC5d7'
        'Name: Velocity'
      }.invoke() | Out-String
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
      [Exception]::new($message),
      'ErrorID',
      [System.Management.Automation.ErrorCategory]::InvalidData,
      'Okta'
      )
      $pscmdlet.ThrowTerminatingError($errorRecord)
    }
    else {
      $settings = [hashtable]::new()
      $behavior = (Get-OktaBehaviorRule -Identity $Identity)
      if ($behavior.count -eq 1) {
        $behaviorID = $behavior.ID
        
        if ($PSBoundParameters['VelocityKPH']) {
          $settings.velocityKph = $PSBoundParameters['VelocityKPH']
        } 
        if ($PSBoundParameters['MaxEvents']) {
          $settings.maxEventsUsedForEvaluation = $PSBoundParameters['MaxEvents']
        }
        if ($PSBoundParameters['MinEvents']) {
          $settings.minEventsUsedForEvaluation = $PSBoundParameters['MinEvents']
        }
        if ($type -eq 'Location') {
          $settings.granularity = if ($PSBoundParameters['Granularity']) {
            ($PSBoundParameters['Granularity']).ToUpper()
          } 
          else {$behavior.granularity}
        
          if ($PSBoundParameters['Granularity'] -eq 'Lat_Long') {
            $settings.radiusKilometers  = if ($PSBoundParameters['RadiusKilometers']) {
              $PSBoundParameters['RadiusKilometers']
            }
            else {
              $behavior.radiusKilometers
            }
            
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
                                    Default   {$behavior.Type}
                                  }
        $oktaAPI.Body.settings  = $settings
        $oktaAPI.Method         = 'PUT'
        $oktaAPI.EndPoint       = "behaviors/$behaviorID"
        (Invoke-OktaAPI @oktaAPI) | Select-Object -ExpandProperty Settings -Property * -ExcludeProperty Settings, _links
      }
      else {
        $message = {
          "Multiple results returned for $identity"
          'Use Get-OktaBehaviorRule to get the ID.'
        }.invoke() | Out-String
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
          [Exception]::new($message),
          'ErrorID',
          [System.Management.Automation.ErrorCategory]::InvalidResult,
          'Okta'
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
      }
    }
  }
}