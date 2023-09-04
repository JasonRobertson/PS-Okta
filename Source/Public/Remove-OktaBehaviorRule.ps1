function Remove-OktaBehaviorRule {
  [cmdletbinding()]
  param(
    [string]$Identity
  )
  $behaviorID = (Get-OktaBehaviorRule -Identity $Identity).ID
  
  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'DELETE'
  $oktaAPI.Endpoint = "behaviors/$behaviorID"
  Invoke-OktaAPI @oktaAPI
}