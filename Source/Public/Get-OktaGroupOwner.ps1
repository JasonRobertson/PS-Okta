function Get-OktaGroupOwner {
  [CmdletBinding()]
  param(
    [parameter(mandatory,position=0)]
    [string]$Identity,
    [parameter(position=1)]
    [string]$Owner
  )
  $groupId = (Get-OktaGroup -Identity $identity).id
  
  $oktaAPI              = [hashtable]::new()
  $oktaAPI.Endpoint     = "groups/$groupId/owners"
  $oktaAPI.Body         = [hashtable]::new()
  $oktaAPI.Body.filter  = $type

  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    $message = Write-OktaError $PSITEM.Exception.Message
    $pscmdlet.ThrowTerminatingError($message)
  }  
}