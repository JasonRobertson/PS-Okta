function Get-OktaUser {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter( ParameterSetName='Identity', ValueFromPipeline=$true)]
    [string[]]$Identity,
    # Status parameter can be used to list users with a specific status.
    # You can select one or more Active, Provisioned, Deprovisioned, Staged, Recovered, Locked, PasswordExpired
    [parameter(ParameterSetName='Default')]
    [ValidateSet('Active','Provisioned','Deprovisioned','Staged','Recovery','Locked','PasswordExpired')]
    [string]$Status,
    [parameter(ParameterSetName='Default')]
    [datetime]$LastUpdated,
    [parameter(ParameterSetName='Default')]
    [validateRange(1,200)]
    [int]$Limit = 200,
    [parameter(ParameterSetName='Default')]
    [switch]$All
  )
  begin {
    $filterStatus = switch ($status) {
      Active          {'status eq "ACTIVE"'}
      Staged          {'status eq "STAGED"'}
      Recovery        {'status eq "RECOVERY"'}
      Locked          {'status eq "LOCKED_OUT"'}
      Provisioned     {'status eq "PROVISIONED"'}
      Deprovisioned   {'status eq "DEPROVISIONED"'}
      PasswordExpired {'status eq "PASSWORD_EXPIRED"'}
    }
    If ($lastUpdated) {
      $filterLastUpdated = "lastUpdated gt ""$(Get-Date $lastUpdated -Format yyyy-MM-ddThh:mm:ss.fffZ)"""
    }
    $body         = [hashtable]::new()
    $body.limit   = $limit
    $body.filter  = if ($filterStatus -and $LastUpdated){"$filterStatus and $filterLastUpdated" }
                    elseif ($filterStatus) {$filterStatus}
                    elseif ($filterLastUpdated) {$filterLastUpdated}
  }
  process {
    foreach ($userID in $Identity) {
      $Endpoint = switch ($PSCmdlet.ParameterSetName) {
        Default   {"users"}
        Identity  {"users/$userID"}
      }
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Method   = 'GET'
      $oktaAPI.Body     = $body
      $oktaAPI.All      = $all
      $oktaAPI.Endpoint = $Endpoint
    
      try{
        Invoke-OktaAPI @oktaAPI | Select-Object -Property * -ExpandProperty profile -ExcludeProperty profile, type, credentials, _links
      }
      catch {
        $message = "Failed to retrieve Okta User $userID, verify the ID matches one of the examples:
                  ID:               00ub0oNGTSWTBKOLGLNR
                  Login:            isaac.brock@example.com
                  Login Shortname:  isaac.broc"
    
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
  end{}
}