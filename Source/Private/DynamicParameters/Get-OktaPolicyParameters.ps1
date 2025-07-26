function Get-OktaPolicyParameters {
  $dynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

  $includeApp               = [hashtable]::new()
  $includeApp.Name          = 'IncludeApp'
  $includeApp.Type          = 'Int32'
  $includeApp.ValidateRange = 1, 40075
  $includeApp.Position      = 3
  $includeApp.DefaultValue  = 805

  $dynamicParameters.Add([PSCustomObject]$includeApp)

  switch -wildcard ($type) {
    'Authorization Server Policy' {

    }
    'Access Policy' {
      
    }
    'IDP Discovery' {}
    'MFA Enroll' {}
    'Okta Sign On' {}
    'Password' {}
    'Profile Enrollment' {}
  }
  $dynamicParameters | New-DynamicParameter
}