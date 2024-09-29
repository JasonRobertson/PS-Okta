function Enable-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName ='Identity')]
  param (
    [parameter(ParameterSetName='Identity')]
    [string]$Identity
  )
  $ruleID = (Get-OktaGroupRule -Identity $Identity).where({$_.Name -eq $identity}).id

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = "groups/rules/$ruleID/lifecycle/activate"
  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}