function Get-OktaAppCertificate {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$AppID,
    [parameter(ParameterSetName='KeyID')]
    [string]$KeyID
  )
  begin {
    Write-Verbose "BEGIN Block: Start"
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    #Verify the appID is present in the okta org/tenant.
    try {
      $oktaApp = Get-OktaApp -AppID $AppID
    }
    catch {
      Write-Host -ForegroundColor Red "$appID cannot be found in $($connectionOkta.domain) Okta tenant"
      break
    }

    $uri = switch ($PSCmdlet.ParameterSetName) {
      KeyID   {"$oktaurl/apps/$AppID/credentials/keys/$keyID"}
      default {"$oktaurl/apps/$AppID/credentials/keys"}
    }

    #region Build Headers
    Write-Verbose "Build Headers: Start"
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    Write-Verbose "Build Headers: Complete"
    #endregion
    #region Build Web Request
    $restMethod                 = [hashtable]::new()
    $restMethod.Uri             = $uri
    $restMethod.Method          = 'GET'
    $restMethod.Headers         = $headers
    #$restMethod.Body            = $body | ConvertTo-Json
    #endregion
    Write-Verbose "BEGIN Block: End"
  }
  process {
    Write-Verbose "PROCESS Block: Start"
    Invoke-RestMethod @restMethod
    Write-Verbose "PROCESS Block: End"
  }
  end {}
}