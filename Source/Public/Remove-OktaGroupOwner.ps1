function Remove-OktaGroupOwner {
  [CmdletBinding()]
  param(
    [parameter(Mandatory,Position=0)]
    [string]$Identity,
    [parameter(Mandatory,Position=1)]
    [string]$Owner,
    [parameter(Mandatory,Poistion=2)]
    [validateset('Group','User')]
    [string]$Type
  )
  $groupId = (Get-OktaGroup -Identity $identity).id
  $ownerId = switch ($type) {
      User  {(Get-OktaUser -Identity $owner).id }
      Group {(Get-OktaGroup -Identity $owner).id}
  }
  
  $oktaAPI            = [hashtable]::new()
  $oktaAPI.Endpoint   = "groups/$groupId/owners"
  $oktaAPI.Body       = [hashtable]::new()
  $oktaAPI.Body.id    = $ownerId
  $oktaAPI.Body.type  = $type
  $oktaAPI.Method     = 'DELETE'

  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    $message = Write-OktaError $PSITEM.Exception.Message
    $pscmdlet.ThrowTerminatingError($message)
  }
}