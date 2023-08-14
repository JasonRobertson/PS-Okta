function Add-OktaGroupMember {
  [CmdletBinding()]
  param (
    [Parameter(Mandatory)]
    #Identity parameter accepts ID or Name
    # ID:   00g786gzjzv02mK3Z5d7
    # Name: Everyone
    [string]$Identity,
    # Member parameter accepts ID, Login or Login Shortname
    # ID:               00ub0oNGTSWTBKOLGLNR
    # Login:            isaac.brock@example.com
    # Login Shortname:  isaac.brock
    [Parameter(Mandatory)]
    [string[]]$Member
  )
  begin{}
  process{
    try {
      $groupID = (Get-OktaGroup -Identity $Identity).id
    }
    catch {
      Write-Error $PSItem.Exception.Message -ErrorAction Stop
    }
      foreach ($user in $member) {
        try {
          $oktaUser = Get-OktaUser -Identity $user
          switch ($oktaUser.status){
            DEPROVISIONED {
              Write-Warning "User $user is deprovisioned, skipping user"
            }
            Default {
              $userID           = $oktaUser.Id
              $oktaAPI          = [hashtable]::New()
              $oktaAPI.Method   = "PUT"
              $oktaAPI.Endpoint = "groups/$groupID/users/$userID"
              Invoke-OktaAPI @oktaAPI
            }
          }
        }
        catch {
          Write-Error $PSItem.Exception.Message
        }
      }
  }
  end{}
}