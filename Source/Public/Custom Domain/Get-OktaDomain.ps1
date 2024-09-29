function Get-OktaDomain {
  [cmdletbinding()]
  param(
    $Identity
  )
  try {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Endpoint = 'domains'

    # Required to complete _Links exclusion. Okta is returning the domains in a Domains list. 
    $response = (Invoke-OktaAPI @oktaAPI).domains | Select-Object -ExcludeProperty _links

    $output = if ($identity) {
      switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
        True {$response.Where({$_.Id -like $identity -or $_.Domain -like $identity})}
        False {$response.Where({$_.Id -eq $identity -or $_.Domain -eq $identity})}
      }
    }
    else {
      $response
    }
    $output 
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}