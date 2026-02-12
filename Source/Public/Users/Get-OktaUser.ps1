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
    # User type (profile.userType)
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
  begin {
    # Build Okta filter expression from the various filter parameters
    $filters = @()

    $filterStatus = switch ($status) {
      Active          {'status eq "ACTIVE"'}
      Staged          {'status eq "STAGED"'}
      Recovery        {'status eq "RECOVERY"'}
      Locked          {'status eq "LOCKED_OUT"'}
      Provisioned     {'status eq "PROVISIONED"'}
      Deprovisioned   {'status eq "DEPROVISIONED"'}
      PasswordExpired {'status eq "PASSWORD_EXPIRED"'}
    }
    if ($filterStatus)  { $filters += $filterStatus}

    if ($LastUpdated) {
      $filterLastUpdated = "lastUpdated gt ""$(Get-Date $lastUpdated -Format yyyy-MM-ddThh:mm:ss.fffZ)"""
      $filters += $filterLastUpdated
    }

    if ($Manager)       { $filters += "profile.manager eq ""$Manager""" }
    if ($Country)       { $filters += "profile.country eq ""$Country""" }
    if ($CountryCode)   { $filters += "profile.countryCode eq ""$CountryCode""" }
    if ($City)          { $filters += "profile.city eq ""$City""" }
    if ($WorkerType)    { $filters += "profile.workerType eq ""$WorkerType""" }
    if ($Domain)        { $filters += "profile.login co ""$Domain""" }
    if ($Department)    { $filters += "profile.department eq ""$Department""" }
    if ($Division)      { $filters += "profile.division eq ""$Division""" }
    if ($Organization)  { $filters += "profile.organization eq ""$Organization""" }
    if ($CostCenter)    { $filters += "profile.costCenter eq ""$CostCenter""" }
    if ($EmployeeNumber){ $filters += "profile.employeeNumber eq ""$EmployeeNumber""" }
    if ($UserType)      { $filters += "profile.userType eq ""$UserType""" }

    $body         = [hashtable]::new()
    $body.limit   = $limit
    if ($filters.Count -gt 0) {
      $body.filter = $filters -join ' and '
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