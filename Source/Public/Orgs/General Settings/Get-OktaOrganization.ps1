function Get-OktaOrganization {
  [CmdletBinding()]
  param()
  Invoke-OktaAPI -Endpoint org
}