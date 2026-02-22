function Get-OktaUser {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(Position=0,ParameterSetName='Identity', ValueFromPipeline=$true)]
    [string[]]$Identity,
    # Status parameter can be used to list users with a specific status.
    # You can select one or more Active, Provisioned, Deprovisioned, Staged, Recovered, Locked, PasswordExpired
    [parameter(ParameterSetName='Default')]
    [ValidateSet('Active','Provisioned','Deprovisioned','Staged','Recovery','Locked','PasswordExpired')]
    [string]$Status,
    # Filter by first name (profile.firstName)
    [parameter(ParameterSetName='Default')]
    [string]$FirstName,
    # Filter by last name (profile.lastName)
    [parameter(ParameterSetName='Default')]
    [string]$LastName,
    # Filter by manager (profile.manager)
    [parameter(ParameterSetName='Default')]
    [string]$Manager,
    # Filter by country name (profile.country)
    [parameter(ParameterSetName='Default')]
    [string]$Country,
    # Filter by country code, e.g. US, GB (profile.countryCode)
    [parameter(ParameterSetName='Default')]
    [string]$CountryCode,
    # Filter by city (profile.city)
    [parameter(ParameterSetName='Default')]
    [string]$City,
    # Filter by worker type (profile.workerType)
    [parameter(ParameterSetName='Default')]
    [string]$WorkerType,
    # Filter by email/login domain contained in profile.login
    [parameter(ParameterSetName='Default')]
    [string]$Domain,
    # Recommended additional filters
    # Department (profile.department)
    [parameter(ParameterSetName='Default')]
    [string]$Department,
    # Division (profile.division)
    [parameter(ParameterSetName='Default')]
    [string]$Division,
    # Organization (profile.organization)
    [parameter(ParameterSetName='Default')]
    [string]$Organization,
    # Cost center (profile.costCenter)
    [parameter(ParameterSetName='Default')]
    [string]$CostCenter,
    # Employee number / ID (profile.employeeNumber)
    [parameter(ParameterSetName='Default')]
    [string]$EmployeeNumber,
    # Filter by profile userType (static profile field, e.g. Employee, Contractor)
    [parameter(ParameterSetName='Default')]
    [string]$UserType,
    [parameter(ParameterSetName='Default')]
    [datetime]$LastUpdated,
    [parameter(ParameterSetName='Default')]
    [parameter(ParameterSetName='Identity')]
    [switch]$RecoveryQuestion,
    [parameter(ParameterSetName='Default')]
    [validateRange(1,200)]
    [int]$Limit = 200,
    [parameter(ParameterSetName='Default')]
    [switch]$All
  )
  dynamicparam {
    $userTypeDisplayNames = (Get-OktaUserType -ErrorAction SilentlyContinue | ForEach-Object { $_.displayName })
    $param = [hashtable]::new()
    $param.Name = 'Type'
    $param.Type = [string]
    $param.ParameterSetName = 'Default'
    if ($userTypeDisplayNames -and $userTypeDisplayNames.Count -gt 0) {
      $param.ValidateSet = [string[]]$userTypeDisplayNames
    }
    $dict = [PSCustomObject]$param | New-DynamicParameter
    # ArgumentCompleter so tab completion shows user types instead of path completion (e.g. on macOS)
    if ($dict.ContainsKey('Type')) {
      $completer = [System.Management.Automation.ArgumentCompleterAttribute]::new({
        param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
        $displayNames = Get-OktaUserType -ErrorAction SilentlyContinue | ForEach-Object { $_.displayName }
        if ($wordToComplete) {
          @($displayNames) | Where-Object { $_ -like "${wordToComplete}*" }
        } else {
          @($displayNames)
        }
      })
      $dict['Type'].Attributes.Add($completer)
    }
    $dict
  }
  begin {
    # Build Okta search expression from the various filter parameters (body.search is required for list/search)
    $search = [System.Collections.ArrayList]::new()

    $statusFilter = switch ($status) {
      Active          {'status eq "ACTIVE"'}
      Staged          {'status eq "STAGED"'}
      Recovery        {'status eq "RECOVERY"'}
      Locked          {'status eq "LOCKED_OUT"'}
      Provisioned     {'status eq "PROVISIONED"'}
      Deprovisioned   {'status eq "DEPROVISIONED"'}
      PasswordExpired {'status eq "PASSWORD_EXPIRED"'}
    }
    if ($statusFilter)  { [void]$search.Add($statusFilter) }

    if ($LastUpdated) {
      $searchLastUpdated = "lastUpdated gt ""$(Get-Date $lastUpdated -Format yyyy-MM-ddThh:mm:ss.fffZ)"""
      [void]$search.Add($searchLastUpdated)
    }

    if ($FirstName)     { [void]$search.Add("profile.firstName eq ""$FirstName""") }
    if ($LastName)      { [void]$search.Add("profile.lastName eq ""$LastName""") }
    if ($Manager)       { [void]$search.Add("profile.manager eq ""$Manager""") }
    if ($Country)       { [void]$search.Add("profile.country eq ""$Country""") }
    if ($CountryCode)   { [void]$search.Add("profile.countryCode eq ""$CountryCode""") }
    if ($City)          { [void]$search.Add("profile.city eq ""$City""") }
    if ($WorkerType)    { [void]$search.Add("profile.workerType eq ""$WorkerType""") }
    if ($Domain)        { [void]$search.Add("profile.login co ""$Domain""") }
    if ($Department)    { [void]$search.Add("profile.department eq ""$Department""") }
    if ($Division)      { [void]$search.Add("profile.division eq ""$Division""") }
    if ($Organization)  { [void]$search.Add("profile.organization eq ""$Organization""") }
    if ($CostCenter)    { [void]$search.Add("profile.costCenter eq ""$CostCenter""") }
    if ($EmployeeNumber){ [void]$search.Add("profile.employeeNumber eq ""$EmployeeNumber""") }
    if ($UserType)       { [void]$search.Add("profile.userType eq ""$UserType""") }
    if ($PSBoundParameters['Type']) {
      $userTypeValue = $PSBoundParameters['Type']
      $resolvedId = (Get-OktaUserType -ErrorAction SilentlyContinue | Where-Object { $_.displayName -eq $userTypeValue -or $_.name -eq $userTypeValue } | Select-Object -First 1 -ExpandProperty id)
      $idForFilter = if ($resolvedId) { $resolvedId } else { $userTypeValue }
      [void]$search.Add("type.id eq ""$idForFilter""")
    }

    $body         = [hashtable]::new()
    $body.limit   = $limit
    if ($search.Count -gt 0) {
      $body.search = $search -join ' and '
    }
  }
  process {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'GET'
    $oktaAPI.Body     = $body
    $oktaAPI.All      = $all

    $response = switch ($PSCmdlet.ParameterSetName) {
      Default {
        $oktaAPI.Endpoint = 'users'
        Invoke-OktaAPI @oktaAPI
      }
      Identity {
        foreach ($userID in $Identity) {
          $oktaAPI.Endpoint = "users/$userID"
          try{
            Invoke-OktaAPI @oktaAPI
          }
          catch {
            $message = {
              "Failed to retrieve Okta User $userID, verify the ID matches one of the examples:"
              'ID:              00ub0oNGTSWTBKOLGLNR'
              'Login:           isaac.brock@example.com'
              'Login Shortname: isaac.broc'
            }.invoke() | Out-String      
            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
              [Exception]::new($message),
              'ErrorID',
              [System.Management.Automation.ErrorCategory]::ObjectNotFound,
              'Okta'
            )
            $pscmdlet.ThrowTerminatingError($errorRecord)
          }  
        }
      }
    }
    foreach ($entry in $response) {
      switch ($recoveryQuestion) {
        true {
          $entry | Select-Object -Property *, @{name='recoveryQuestion';e={$_.credentials.recovery_question.question}} -ExpandProperty profile -ExcludeProperty profile, type, credentials, _links
        }
        false {
          $entry | Select-Object -Property * -ExpandProperty profile -ExcludeProperty profile, type, credentials, _links
        }
      }
    }
  }
  end{}
}