function Remove-OktaGroup {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Identity
  )
  process {
    try {
      $groupID = (Get-OktaGroup -Identity $Identity).id

      $oktaAPI          = [hashtable]::new()
      $oktaAPI.Method   = 'DELETE'
      $oktaAPI.Endpoint = "groups/$groupID"
      Invoke-OktaAPI @oktaAPI
    }
    catch {
      Write-OktaError $PSItem.Exception.Message
    }
  }
}