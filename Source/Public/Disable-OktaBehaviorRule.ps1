function Disable-OktaBehaviorRule {
  [cmdletbinding()]
  param(
    [string]$Identity
  )
  if ([wildcardpattern]::ContainsWildcardCharacters($identity)){
    $message = {
      'Wildcard is not supported; verify the identity matches one of the examples:'
      'ID:   0oa786gznlVSf15sC5d7'
      'Name: Velocity'
    }.invoke() | Out-String

    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [Exception]::new($message),
    'ErrorID',
    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
    'Okta'
    )
    $pscmdlet.ThrowTerminatingError($errorRecord)
  }
  else {
    $behaviorID = (Get-OktaBehaviorRule -Identity $Identity).ID
    if ($behaviorID.count -eq 1) {
      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Method   = 'POST'
      $oktaAPI.Endpoint = "behaviors/$behaviorID/lifecycle/deactivate"
      try {
        (Invoke-OktaAPI @oktaAPI) | Select-Object -Property * -ExpandProperty Settings -ExcludeProperty Settings, _links
      }
      catch {
        Write-Error $PSItem.Exception.Message
      }
    }
  }
}