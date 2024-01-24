function Add-OktaGroupOwner {
  [CmdletBinding()]
  param(
    [parameter(Mandatory,Position=0)]
    [string]$Identity,
    [validateset('Group','User')]
    [string]$Type
  )
  $groupId = (Get-OktaGroup -Identity $identity).id
  
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Endpoint   = "groups/$groupId/owners"
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.filter = $type
  $oktaAPI.Method     = 'POST'

  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    $message = Write-OktaError $PSITEM.Exception.Message
    $pscmdlet.ThrowTerminatingError($message)
  }
}