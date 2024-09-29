function Get-OktaGroup {
  [CmdletBinding()]
  param (
    [parameter()]
    [alias('GroupID','ID')]
    [string]$Identity,
    # Type parameter is used to filter groups based on type
    # App:      Groups Profile and memberships are imported and must be managed within the application that imported the Group.
    #           Note: Active Directory and LDAP Groups also have APP_GROUP type.
    # Okta:     Groups Profile and memberships are directly managed in Okta via static assignments or indirectly through Group rules
    # BuiltIn:  Group Profile and memberships are managed by Okta and can't be modified
    #[parameter(ParameterSetName='GroupType')]
    [ValidateSet('App','BuiltIn', 'Okta')]
    [string]$Type,
    [validaterange(1,10000)]
    [int]$Limit = 10000,
    # Profile is a switch parameter used to only return the profile of the object.
    [alias('GroupProfile')]
    [switch]$All
  )
  $groupType  = switch ($type) {
                  App     {'APP_GROUP'}
                  Okta    {'OKTA_GROUP'}
                  BuiltIn {'BUILT_IN'}
                }
  $search = if ($groupType) {
              "type eq ""$groupType"""
            }
            elseif ($identity) {
              "profile.name eq ""$identity"" or id eq ""$Identity"""
            }
            elseif ($groupType -and $identity) {
              "type eq ""$groupType"" and (profile.name eq ""$identity"" or id eq ""$Identity"")"
            }
  $body         = [hashtable]::new()
  $body.limit   = $limit
  $body.search  = switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
                    true  {$search.Replace('*','').Replace('profile.name eq','profile.name sw')}
                    false {$search}
                  }

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Body     = $body
  $oktaAPI.Endpoint = 'groups'
  $oktaAPI.All      = $all

  $results = (Invoke-OktaAPI @oktaAPI) | Select-Object * -ExpandProperty profile -ExcludeProperty objectClass, profile, type,_links
  switch (-not $results) {
    True  {
      $message = {"Failed to retrieve Okta group $identity, verify the ID matches one of the examples:"}.invoke()
      $message.Add('ID:   00ub0oNGTSWTBKOLGLNR')
      $message.Add('Name: Everyone')
  
      $errorRecord = [System.Management.Automation.ErrorRecord]::new(
        [Exception]::new(($message | Out-String)),
        'ErrorID',
        [System.Management.Automation.ErrorCategory]::ObjectNotFound,
        'Okta'
      )
      $pscmdlet.ThrowTerminatingError($errorRecord)
    }
    False {$results}
  }
}