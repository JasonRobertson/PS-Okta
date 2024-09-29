function Remove-OktaAppGroup {
  [cmdletbinding()]
  param(
    [parameter(Mandatory,postion=0)]
    [string]$Identity,
    [parameter(Mandatory,postion=1)]
    [string[]]$Group
  )
  begin {
    $appId = (Get-OktaApp -Identity $Identity).id
  }
  process {
    if ($appID) {
      try {
        foreach ($entry in $group) {
          $groupID = (Get-Oktagroup -Identity $entry).id
          if ($groupID) {
            $oktaAPI          = [hashtable]::new()
            $oktaAPI.endpoint = "apps/$appID/groups/$groupID"
            $oktaAPI.Method   = 'DELETE'
            Invoke-OktaAPI @oktaAPI
          }
        }
      }
      catch {
        Write-Error $PSItem.Exception.Message
      }
    }
  }
}