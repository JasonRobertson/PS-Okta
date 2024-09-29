function Disable-OktaUser {
  [CmdletBinding(DefaultParameterSetName='UserID')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(ParameterSetName='UserID')]
    [string]$Identity,
    [switch]$SendEmail
  )
  if ((Invoke-OktaAPI -EndPoint users/$identity).status -eq 'DEPROVISIONED') {
    Write-Warning "$identity is already deactivated"
  }
  else {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = switch ($SendEmail) {
      true  {"users/$identity/lifecycle/deactivate?sendEmail=true"}
      false {"users/$identity/lifecycle/deactivate?sendEmail=false"}
    }
    try {
      Invoke-OktaAPI @oktaAPI
      Write-Host "Successfully deactivated $identity"
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}