function Get-OktaUserGroups {
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [string]$Identity,
    [switch]$UserProfile,
    [int]$Limit = 200,
    [switch]$All
  )
  begin {
    #region Static Variables
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    #region Build the headers
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion

    #region Build the body of the web request
    Write-Verbose 'Build the body of the web request'
    $body         = [hashtable]::new()
    $body.limit   = $Limit
    #endregion

    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = -join "$oktaUrl/users/$identity/groups"
    $webRequest.Body            = $body
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    switch ($all) {
      False { 
        Write-Verbose "All Switch Present: $false"
        $response = Invoke-WebRequest @webRequest
        switch ($UserProfile){
          False { (ConvertFrom-Json $response.Content)        }
          True  { (ConvertFrom-Json $response.Content).Profile}
        }
      }
      True  { Write-Verbose "All Switch Present: $true"
        do{
          $response = Invoke-WebRequest @webRequest
          $webRequest.Uri = $response.RelationLink.next #RelationLink is the recommended approach for pagination from Okta.
          $webRequest.Remove('Body')
          switch ($UserProfile){
            False { (ConvertFrom-Json $response.Content)         }
            True  { (ConvertFrom-Json $response.Content).Profile }
          }
        } until (-not $response.RelationLink.next)
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}