function Get-OktaApp {
  [CmdletBinding(DefaultParameterSetName='Limit')]
  param (
    [parameter(ParameterSetName='AppID')]
    [alias('AppID')]
    [string]$ID,
    [alias('AppName')]
    [string]$Name,
    [ValidateSet('Active', 'Inactive')]
    $Status,
    [parameter(ParameterSetName='Limit')]
    [ValidateRange(1,500)]
    [int]$Limit,
    [parameter(ParameterSetName='Limit')]
    [switch]$All
  )
  begin {
    Write-Verbose "BEGIN Block: Start"
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    #region Build the headers
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion

    Write-Verbose "OktaDomain: $oktaDomain"
    #region Build Headers
    Write-Verbose "Build Headers: Start"
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    Write-Verbose "Build Headers: Complete"
    #endregion
    #region Build Body
    $body       = [hashtable]::new()
    $body.limit = switch ($Limit -ge 1 -or $limit -gt 200){
                    True  {$Limit}
                    False {200}
                  }
    if ($status){
      $body.filter = switch ($status) {
        Active   {'status eq "ACTIVE"'}
        Inactive {'status eq "INACTIVE"'}
      }
    }
    #endregion
    #region Build Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = switch ($pscmdlet.ParameterSetName){
                                    Limit {"$oktaUrl/apps/"}
                                    AppID {"$oktaUrl/apps/$ID"}
                                  }
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    $webRequest.Body            = $body
    #endregion
    Write-Verbose "BEGIN Block: End"
  }
  process {
    Write-Verbose "PROCESS Block: Start"
    switch ($all) {
      True {
        Write-Verbose "All Parameter Present: True"
        do{
          $response = Invoke-WebRequest @webRequest
          $webRequest.Uri = $response.RelationLink.next #RelationLink is the recommended approach for pagination from Okta.
          $webRequest.Remove('Body')
          (ConvertFrom-Json $response.Content)
          Write-Verbose "NextLink present: True"
        } until (-not $response.RelationLink.next)
        Write-Verbose "NextLink present: False"
      }
      False {
        Write-Verbose "All Parameter Present: False"
        $response = switch ($null -eq $userid ) {
          True {
            Write-Verbose "UserID Present: False"
            Invoke-WebRequest @webRequest
          }
          False {
            Write-Verbose "UserID Present: True"
            $body.scope = 'USER'
            foreach ($id in $userID){
              $body.ID    = $id
              $webRequest.Body  = $body
              Invoke-WebRequest @webRequest
            }
          }
        }
        (ConvertFrom-Json $response.Content)
      }
    }
    Write-Verbose "PROCESS Block: End"
  }
  end {
    Write-Verbose "END Block: Start"
    [system.gc]::Collect()
    Write-Verbose "END Block: End"
  }
}