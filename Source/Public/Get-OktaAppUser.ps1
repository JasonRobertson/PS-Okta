function Get-OktaAppUser {
  [CmdletBinding(DefaultParameterSetName='Limit')]
  param (
    [Alias('OktaPreview')]
    [switch]$Preview,
    [parameter(Mandatory)]
    [string]$AppID,
    [parameter(ParameterSetName='UserID')]
    [string]$UserID,
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
    #Verify the appID is present in the okta org/tenant.
    try {
      Write-Verbose "Verifing $appID exists in Okta."
      $appID = (Get-OktaApp -AppID $appID).id
    }
    catch {
      Write-Host -ForegroundColor Red "$appID cannot be found in $domain.okta.com"
      break
    }
    #region Build Headers
    Write-Verbose "Build Headers: Start"
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    Write-Verbose "Build Headers: Complete"
    #endregion
    #region Build Body
    $body       = [hashtable]::new()
    $body.limit = switch ($Limit -ge 1 -or $limit -gt 500){
      True  {$Limit}
      False {500}
    }
    Write-Verbose $($body.limit)
    #endregion
    #region Build Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = "$oktaUrl/apps/$appId/users"
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    $webRequest.Body            = $body
    #endregion
  Write-Verbose "BEGIN Block: End"
  }
  process {
    Write-Verbose "PROCESS Block: Start"

    switch ($PSItem.parametersetname) {
      UserID {
        Write-Verbose "ParameterSetname: $($PSITEM.ParameterSetName)"
        $body.scope = 'USER'
        $body.ID = $id
        $webRequest.Body  = $body
        Invoke-WebRequest @Webrequest
      }
      default {
        Write-Verbose "ParameterSetname: $($PSITEM.ParameterSetName)"
        switch ($all) {
          True {
            Write-Verbose "All Parameter Present: True"
            do{
              $response = Invoke-Webrequest @WebRequest
              if ($response.RelationLink.next){
                Write-Verbose "NextLink present: True"
                #Write-Verbose $resposnse.RelationLink.next
                $webRequest.Uri = $response.RelationLink.next
                $webRequest.Remove('Body')
              }
              (ConvertFrom-Json $response.Content)
            } until (-not $response.RelationLink.next)
            Write-Verbose "NextLink present: False"
          }
          False {
            Write-Verbose "All Parameter Present: False"
            $response = Invoke-Webrequest @Webrequest
            (ConvertFrom-Json $response.Content)
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