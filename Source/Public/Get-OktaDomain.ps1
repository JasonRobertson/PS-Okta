function Get-OktaDomain {
  [cmdletbinding()]
  param(
    $Identity
  )
  try {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Endpoint = 'domains'

    $response = (Invoke-OktaAPI @oktaAPI).domains

    $output = if ($identity) {
      switch ([wildcardpattern]::ContainsWildcardCharacters($identity)) {
        True {$response.Where({$_.Id -like $identity -or $_.Domain -like $identity})}
        False {$response.Where({$_.Id -eq $identity -or $_.Domain -eq $identity})}
      }
    }
    else {
      $response
    }
    $output | Select-Object -ExcludeProperty _links
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}