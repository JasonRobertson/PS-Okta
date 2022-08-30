function Get-OktaGroupMember {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [Alias('GroupID')]
    [string]$ID,
    [ValidateRange(1,200)]
    [int]$Limit = 200,
    [switch]$UserProfile,
    [switch]$All
  )
  begin {
    Write-Verbose "BEGIN Block: Start"
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion

    #region Build the body
    $body         = [hashtable]::new()
    $body.limit   = $Limit
    #endregion

    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = "$oktaUrl/groups/$Id/users"
    $webRequest.Body            = $body
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    switch ($all) {
      False {
          $response = Invoke-WebRequest @webRequest
          switch ($UserProfile){
            True  {(ConvertFrom-Json $response.Content).Profile}
            False {ConvertFrom-Json $response.Content}
          }
        }
      true {
        do{
          $response = Invoke-WebRequest @webRequest
          $webRequest.Uri = $response.RelationLink.next #RelationLink is the recommended approach for pagination from Okta.
          $webRequest.Remove('Body')
          switch ($UserProfile){
            True  {(ConvertFrom-Json $response.Content).Profile}
            False {ConvertFrom-Json $response.Content}
          }
        } until (-not $response.RelationLink.next)
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}