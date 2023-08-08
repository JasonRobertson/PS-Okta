function Add-OktaAppUser {
  [CmdletBinding()]
  param (
    # Identity parameter accepts appId
    # ID: 0oafxqCAJWWGELFTYASJ
    [parameter(Mandatory)]
    [string]$Identity,
    # Member parameter accepts ID, Login or Login Shortname
    # ID:               00ub0oNGTSWTBKOLGLNR
    # Login:            isaac.brock@example.com
    # Login Shortname:  isaac.brock
    [parameter(Mandatory)]
    [string[]]$Member
  )
  begin {
    try {
      $appID = (Get-OktaApp -Identity $Identity).id
    }
    catch {
      
    }
    
  }
  process {
    foreach ($user in $member){
      $oktaUser = Get-OktaUser -Identity $User
      Try {
        #region Add Okta user to Okta App
        Switch ($oktaUser.status){
          Default       {
            $oktaAPI            = [hashtable]::new()
            $oktaAPI.Body       = [hashtable]::new()
            $oktaAPI.Body.id    = $oktaUser.Id
            $oktaAPI.Body.scope = 'USER'
            $oktaAPI.Endpoint   = "apps/" 

            Invoke-OktaAPI @oktaAPI

            #region Build the Rest Method
            Write-Verbose "Build RestMethod Params: Start"
            $webRequest             = [hashtable]::new()
            $webRequest.Uri         = "$oktaUrl/apps/$Identity/users"
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