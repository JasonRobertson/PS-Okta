function Get-OktaUserFactor {
  [CmdletBinding(DefaultParameterSetName='List')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter( ParameterSetName='UserID',
                ValueFromPipeline=$true)]
    [alias('id')]
    [string[]]$Identity
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

      $body         = [hashtable]::new()
      $body.limit   = switch ($limit -eq 200){
                        True  {200}
                        False {$limit}
                      }
      Write-Verbose "Limit: $($body.limit)"
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
    Write-Verbose "ParameterSetName: $($pscmdlet.ParameterSetName)"
    switch ($pscmdlet.ParameterSetName){
      UserID {
        try {
          Write-Verbose 'Getting Okta User ID'
          $oktaUserId = (Get-OktaUser -Identity $identity).id
          foreach ($userID in $oktaUserId) {
            Write-Verbose 'Getting Okta User Factors'
            $webRequest.Uri = "$oktaURL/users/$userID/factors"
            $response = Invoke-WebRequest @webRequest -SkipHttpErrorCheck
            switch -Wildcard ($response.StatusCode){
              200 { ConvertFrom-Json $response.Content }
              40* { Write-Error ($response.Content | ConvertFrom-Json).errorSummary }
            }
          }
        }
        catch { $pscmdlet.ThrowTerminatingError($PSItem) }
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}