function Add-OktaGroupMember {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    [string]$GroupID,
    # UserId parameter accepts ID, Login or Login Shortname
    # ID:               00ub0oNGTSWTBKOLGLNR
    # Login:            isaac.brock@example.com
    # Login Shortname:  isaac.brock
    [Parameter(Mandatory)]
    [string[]]$UserID
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

    #region Build the body
    $body         = [hashtable]::new()
    #endregion

    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Body            = $body
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion

    #region Get Okta Group Member
    $getOktaGroupMember           = [hashtable]::new()
    $getOktaGroupMember.All       = $true
    $getOktaGroupMember.GroupID   = $groupID
    $oktaGroupMembership = (Get-OktaGroupMember @getOktaGroupMember).id
    #endregion
  }
  process {
    ForEach ($id in $userID){
      #region Get Okta User ID
      Try {
        $oktaUser = Get-OktaUser -Identity $id
        Switch ($oktaUser.status){
          Deprovisioned {Write-Warning "$ID is deprovisioned, skipping user"}
          Default       {$oktaId = $oktaUser.ID}
        }
      }
      Catch {
        Write-Warning "Failed to find $ID"
        Write-Warning 'Failed to retrieve Okta User ID, verify the ID provides matches one of the following examples:
        ID:               00ub0oNGTSWTBKOLGLNR
        Login:            isaac.brock@example.com
        Login Shortname:  isaac.brock'
      }
      #endregion
      switch ($oktaGroupMembership -contains $oktaID){
        true  {Write-Output "$id is already added to $GroupID."}
        false {
          #region Add Okta user to Okta Group
          $webRequest.Method  = 'Put'
          $webRequest.Uri     = "$oktaURL/groups/$groupId/users/$oktaID"
          $response = Invoke-WebRequest @webRequest
          Switch ($response.StatusCode) {
            204  {Write-Output "$id successfully added to $GroupID"}
          }
          #endregion
        }
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}