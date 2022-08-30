function Get-OktaAppMember {
  [CmdletBinding(DefaultParameterSetName='Limit')]
  param (
    [parameter(Mandatory)]
    [string]$AppID,
    [parameter(ParameterSetName='UserID')]
    $userID,
    [parameter(ParameterSetName='Limit')]
    [ValidateRange(1,500)]
    [int]$Limit,
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

    #region Build Body
    $body       = New-object -TypeName System.Collections.Hashtable
    $body.limit = switch ($Limit -ge 1 -or $limit -gt 200){
      True  {$Limit}
      False {200}
    }
    Write-Verbose $($body.limit)
    #endregion
    #region Build Web Request
    $webRequest                 = New-object -TypeName System.Collections.Hashtable
    $webRequest.Uri             = "$oktaURL/apps/$appId/users"
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
        Write-Verbose "All Paramter Present: True"
        do{
          $response = Invoke-WebRequest @webRequest
          If ($response.RelationLink.next) {
            $webRequest.Uri = $response.RelationLink.next
            $webRequest.Remove('Body')
          }
          Write-Output (ConvertFrom-Json $response.Content)
          Write-Verbose "NextLink present: True"
        } until (-not $response.RelationLink.next)
        Write-Verbose "NextLink present: False"
      }
      False {
        Write-Verbose "All Paramter Present: False"
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
        Write-Output (ConvertFrom-Json $response.Content)
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