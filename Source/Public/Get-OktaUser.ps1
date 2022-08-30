function Get-OktaUser {
  [CmdletBinding(DefaultParameterSetName='List')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter( ParameterSetName='UserID',
                ValueFromPipeline=$true)]
    [string[]]$Identity,
    # Status parameter can be used to list users with a specific status.
    # You can select one or more Active, Provisioned, Deprovisioned, Staged, Recovered, Locked, PasswordExpired
    [parameter(ParameterSetName='List')]
    [ValidateSet('Active','Provisioned','Deprovisioned','Staged','Recovered','Locked','PasswordExpired')]
    [string]$Status,
    [datetime]$LastUpdated,
    [switch]$UserProfile,
    [parameter(ParameterSetName='List')]
    [validateRange(1,200)]
    [int]$Limit = 200,
    [parameter(ParameterSetName='List')]
    [switch]$All
  )
  begin {
    try {
      #region Static Variables
      #Verify the connection has been established
      $oktaUrl = Test-OktaConnection
      #region Build the headers
      $headers                  = [hashtable]::new()
      $headers.Accept           = 'application/json'
      $headers.Authorization    = Convert-OktaAPIToken
      #endregion
      Write-Verbose 'Web Request Headers: Complete'
      #endregion
      #region Build the body of the web request
      Write-Verbose 'Web Request Body: Start'
      $filterStatus = switch ($status) {
        Active          {'status eq "ACTIVE"'}
        Staged          {'status eq "STAGED"'}
        Recovered       {'status eq "RECOVERY"'}
        Locked          {'status eq "LOCKED_OUT"'}
        Provisioned     {'status eq "PROVISIONED"'}
        Deprovisioned   {'status eq "DEPROVISIONED"'}
        PasswordExpired {'status eq "PASSWORD_EXPIRED"'}
      }
      If ($lastUpdated) {
        $filterLastUpdated = "lastUpdated gt ""$(Get-Date $lastUpdated -Format yyyy-MM-ddThh:mm:ss.fffZ)"""
      }
      $body         = [hashtable]::new()
      $body.limit   = switch ($limit -eq 200){
                        True  {200}
                        False {$limit}
                      }
      Write-Verbose "Limit: $($body.limit)"
      $body.filter = switch ($null -eq $filterStatus){
                        True  {
                          switch ($null -eq $filterLastUpdated){
                            False { $filterLastUpdated }
                          }
                        }
                        False {
                          switch ($null -eq $filterLastUpdated){
                            True  { $filterStatus }
                            False { "$filterStatus and $filterLastUpdated" }
                          }
                        }
                      }
      Write-Verbose 'Web Request Body: Complete'
      Write-Debug $body
      #endregion
      #region Build the Web Request
      $webRequest                 = [hashtable]::new()
      $webRequest.Body            = $body
      $webRequest.Method          = 'GET'
      $webRequest.Headers         = $headers
      $webRequest.UseBasicParsing = $true
      #endregion
    }
    catch {
      $pscmdlet.ThrowTerminatingError($PSItem)
    }
  }
  process {
    try {
      Write-Verbose "ParameterSetName: $($pscmdlet.ParameterSetName)"
      switch ($pscmdlet.ParameterSetName){
        List {
          $webRequest.Uri = "$oktaUrl/users/"
          switch ($all) {
            True  {
              Write-Verbose "All Switch Present: $true"
              do{
                $response = Invoke-WebRequest @webRequest -SkipHttpErrorCheck
                switch -Wildcard ($response.StatusCode){
                  40* {
                    Write-Error ($response.Content | ConvertFrom-Json).errorSummary
                  }
                  200 {
                    If ($response.RelationLink.next) {
                      $webRequest.Uri = $response.RelationLink.next
                      $webRequest.Remove('Body')
                    }
                    switch ($userProfile){
                      True  {(ConvertFrom-Json $response.Content).Profile}
                      False {(ConvertFrom-Json $response.Content)}
                    }
                  }
                }
              }
              until (-not $response.RelationLink.next)
            }
            False {
              Write-Verbose "All Switch Present: $false"
              $response = Invoke-WebRequest @webRequest -SkipHttpErrorCheck
              switch -Wildcard ($response.StatusCode){
                40* {
                  Write-Error ($response.Content | ConvertFrom-Json).errorSummary
                }
                200 {
                  switch ($UserProfile){
                    True  {(ConvertFrom-Json $response.Content).Profile}
                    False {ConvertFrom-Json $response.Content}
                  }
                }
              }
            }
          }
        }
        UserID {
          foreach ($entry in $identity){
            Write-Verbose "All Switch Present: $false"
            $webRequest.Uri = "$oktaURL/users/$entry"
            $response = Invoke-WebRequest @webRequest -SkipHttpErrorCheck
            switch -Wildcard ($response.StatusCode){
              40* {
                Write-Error ($response.Content | ConvertFrom-Json).errorSummary
              }
              200 {
                switch ($UserProfile){
                  True  {(ConvertFrom-Json $response.Content).Profile}
                  False {ConvertFrom-Json $response.Content}
                }
              }
            }
          }
        }
      }
    }
    catch{
      $pscmdlet.ThrowTerminatingError($PSItem)
    }
  }
  end {
    [system.gc]::Collect();
  }
}