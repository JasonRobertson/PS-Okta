function Get-OktaApp {
  [CmdletBinding()]
  param (
    [string]$Identity,
    [ValidateSet('Active', 'Inactive')]
    $Status,
    [ValidateRange(1,500)]
    [int]$Limit = 500,
    [switch]$All
  )
  $filter = switch ($status) {
    Active   {'status eq "ACTIVE"'}
    Inactive {'status eq "INACTIVE"'}
  }

  $query = switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
    True  {$Identity.Replace('*','')}
    False {$Identity}
  }

  $oktaAPI              = [hashtable]::new()
  $oktaAPI.All          = $all
  $oktaAPI.Body         = [hashtable]::new()
  $oktaAPI.Body.q       = $query
  $oktaAPI.Body.limit   = $limit
  $oktaAPI.Body.filter  = $filter
  $oktaAPI.Endpoint     = 'apps'
  
  switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
    True  {Invoke-OktaAPI @oktaAPI}
    False {(Invoke-OktaAPI @oktaAPI).where({$_.Label -eq $Identity -or $_.ID -eq $Identity})}
  }
}