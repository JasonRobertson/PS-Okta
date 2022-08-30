function Add-OktaAppUser {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$AppID,
    # UserId parameter accepts ID, Login or Login Shortname
    # ID:               00ub0oNGTSWTBKOLGLNR
    # Login:            isaac.brock@example.com
    # Login Shortname:  isaac.brock
    [parameter(Mandatory)]
    [string[]]$UserID
  )
  begin {
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    #region Build the headers
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion
  }
  process {
    ForEach ($id in $userID){
      Try {
        #region Verify/Get Okta User ID
        Try {
          $oktaUser = Get-OktaUser -Identity $id
        }
        Catch {
          Write-Warning "Failed to find $ID"
          Write-Warning 'Failed to retrieve Okta User ID, verify the ID matches one of the examples:
          ID:               00ub0oNGTSWTBKOLGLNR
          Login:            isaac.brock@example.com
          Login Shortname:  isaac.brock'
        }
        #endregion
        #region Add Okta user to Okta App
        Switch ($oktaUser.status){
          Default       {
            #region Build the body
            $body         = [hashtable]::new()
            $body.id          = $oktaUser.Id
            $body.scope       = 'USER'
            #endregion
            #region Build the Rest Method
            Write-Verbose "Build RestMethod Params: Start"
            $webRequest             = [hashtable]::new()
            $webRequest.Uri         = "$oktaUrl/apps/$appId/users"
            $webRequest.Body        = ConvertTo-JSON $body
            $webRequest.Method      = 'POST'
            $webRequest.Headers     = $headers
            $webRequest.ContentType = 'application/json'
            Write-Verbose "Build RestMethod Params: Complete"
            Try{
              Write-Verbose "Invoke RestMethod"
              Invoke-WebRequest @webRequest
            }
            Catch {
              Write-Warning $PSItem.Exception.Message
            }
            #endregion
           }
          Deprovisioned { Write-Warning "$ID is deprovisioned, skipping user" }
        }
        #endregion
      }
      catch{}
    }
  }
  end {
    [system.gc]::Collect();
  }
}