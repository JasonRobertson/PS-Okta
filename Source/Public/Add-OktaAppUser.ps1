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
  begin {}
  process {
    $appID = (Get-OktaApp -Identity $Identity).id
    if ($appID) {
      foreach ($user in $member){
        $oktaUser = Get-OktaUser -Identity $User
        Switch ($oktaUser.status){
          DEPROVISIONED {
            Write-Warning "$ID is deprovisioned, skipping user"
          }
          Default { 
            $oktaAPI            = [hashtable]::new()
            $oktaAPI.Body       = [hashtable]::new()
            $oktaAPI.Body.id    = $oktaUser.Id
            $oktaAPI.Body.scope = 'USER'
            $oktaAPI.Method     = 'POST'
            $oktaAPI.Endpoint   = "apps/$appid/users" 

            Invoke-OktaAPI @oktaAPI
          }
        }
      }
    }
  }
  end {}
}