function Get-OktaAppGroup {
  [CmdletBinding(DefaultParameterSetName='Limit')]
  param (
    [parameter(Mandatory)]
    [alias('AppID')]
    [string]$ID,
    [parameter(ParameterSetName='GroupID')]
    [string]$GroupID,
    [parameter(ParameterSetName='Limit')]
    [ValidateRange(1,500)]
    [int]$Limit,
    [switch]$Profile,
    [parameter(ParameterSetName='Limit')]
    [switch]$all
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
    Write-Verbose "Build Headers: Complete"
    #endregion
    #region Build Body
    $body       = [hashtable]::new()
    $body.limit = switch ($Limit -ge 1 -or $limit -gt 200){
                    True  {$Limit}
                    False {200}
                  }
    Write-Verbose $($body.limit)
    #endregion
    #region Build Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = "$oktaURL/apps/$Id/groups"
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
          foreach ($entry in (ConvertFrom-Json $response.Content)) {
            switch ($Profile) {
              true  {(Get-OktaGroup -GroupID $entry.ID).Profile}
              false {Get-OktaGroup -GroupID $entry.ID}
            }
          }
          Write-Verbose "NextLink present: True"
        } until (-not $response.RelationLink.next)
        Write-Verbose "NextLink present: False"
      }
      False {
        Write-Verbose "All Parameter Present: False"
        $response = switch ($null -eq $groupID ) {
          True {
            Write-Verbose "GroupID Present: False"
            Invoke-WebRequest @webRequest
          }
          False {
            Write-Verbose "GroupID Present: True"
            #$body.scope = 'Group'
            foreach ($id in $groupID){
              $body.ID    = $id
              $webRequest.Body  = $body
              Invoke-WebRequest @webRequest
            }
          }
        }
        foreach ($entry in (ConvertFrom-Json $response.Content)) {
          switch ($Profile) {
            true  {(Get-OktaGroup -GroupID $entry.ID).Profile}
            false {Get-OktaGroup -GroupID $entry.ID}
          }
        }
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