function Set-OktaGroup {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [alias('ID')]
    [string]$Identity,
    [string]$Name,
    [string]$Description
  )
  process {
    try {
      $group = Get-OktaGroup -Identity $Identity
      if ($group.Type -eq 'OKTA_GROUP') {
        $body                     = [hashtable]::new()
        $body.profile             = [hashtable]::new()
        $body.profile.name        = if ($name) {$name} else {$group.name}
        $body.profile.description = if ($description) {$description} else {$group.description}

        $oktaAPI          = [hashtable]::new()
        $oktaAPI.Body     = $body
        $oktaAPI.Method   = 'PUT'
        $oktaAPI.Endpoint = "groups/$($group.id)"

        Invoke-OktaAPI @oktaAPI | Select-Object * -ExcludeProperty objectClass, profile,_links -ExpandProperty profile
      }
      else {
        Write-OktaError "You can only modify groups of the OKTA_GROUP type. App_Groups are updated by App imports such as Active Directory Groups."
      }
    }
    catch {
      Write-OktaError $PSItem.Exception.Message
    }
  }
}