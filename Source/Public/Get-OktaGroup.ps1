function Get-OktaGroup {
  [CmdletBinding(DefaultParameterSetName='GroupID')]
  param (
    #
    [parameter(ParameterSetName='GroupID')]
    [alias('GroupID')]
    [string]$ID,
    [parameter(ParameterSetName='GroupName')]
    [alias('GroupName')]
    [string]$Name,
    # Type parameter is used to filter groups based on type
    # App:      Groups Profile and memberships are imported and must be managed within the application that imported the Group.
    #           Note: Active Directory and LDAP Groups also have APP_GROUP type.
    # Okta:     Groups Profile and memberships are directly managed in Okta via static assignments or indirectly through Group rules
    # BuiltIn:  Group Profile and memberships are managed by Okta and can't be modified
    #[parameter(ParameterSetName='GroupType')]
    [ValidateSet('App','BuiltIn', 'Okta')]
    [string]$Type,
    [validaterange(1,10000)]
    [int]$Limit,
    # Profile is a switch parameter used to only return the profile of the object.
    [alias('GroupProfile')]
    [switch]$Profile,
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

    $groupType = switch ($type) {
      App     {'APP_GROUP'}
      Okta    {'OKTA_GROUP'}
      BuiltIn {'BUILT_IN'}
    }

    #region Build the body of the web request
    Write-Verbose 'Build the body of the web request'
    $body         = [hashtable]::new()
    if ($limit) {
      $body.limit   = $Limit
      Write-Debug "Limit: $([pscustomobject]$body.limit)"
    }
    $body.search = if ($groupType -and $name) {
       "type eq ""$groupType"" and profile.name sw ""$name"""
    }
    elseif ($groupType -and -not $name) {
      "type eq ""$groupType"""
    }
    elseif (-not $groupType -and $name) {
      "profile.name sw ""$name"""
    }
    Write-Debug "Search: $([pscustomobject]$body.search)"
    #endregion
    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = Switch($PSCmdlet.ParameterSetName){
                                    GroupName   { "$oktaURL/groups/"}
                                    GroupID     { "$oktaURL/groups/$ID"}
                                  }
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
          switch ($profile){
            True  {(ConvertFrom-Json $response.Content).Profile}
            False {ConvertFrom-Json $response.Content}
          }
        }
      true {
       do{
          $response = Invoke-WebRequest @webRequest
          $webRequest.Uri = $response.RelationLink.next #RelationLink is the recommended approach for pagination from Okta.
          $webRequest.Remove('Body')
          switch ($profile){
            True  {(ConvertFrom-Json $response.Content).Profile}
            False {ConvertFrom-Json $response.Content}
          }
        } until (-not $response.RelationLink.next)
      }
    }
  }
  end {
    [system.gc]::Collect()
  }
}