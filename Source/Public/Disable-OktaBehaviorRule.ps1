function Disable-OktaBehaviorRule {
  [cmdletbinding()]
  param(
    [string]$Identity
  )
  if ([wildcardpattern]::ContainsWildcardCharacters($identity)){
    $message = {}.invoke()
    $message.Add('Wildcard is not supported; verify the identity matches one of the examples:')
    $message.Add('ID:   0oa786gznlVSf15sC5d7')
    $message.Add('Name: Velocity')

    $errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [Exception]::new(($message | Out-String)),
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
      (Invoke-OktaAPI @oktaAPI) | Select-Object -Property * -ExpandProperty Settings -ExcludeProperty Settings, _links
    }
  }
}