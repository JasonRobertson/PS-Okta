function Get-OktaUserAppAssignment {
  [cmdletbinding()]
  param(
    [parameter(Mandatory, position=0,ValueFromPipelineByPropertyName)]
    [alias('id','login')]
    [string]$Identity
  )
  process {
    $oktaUser = (Get-OktaUser -Identity $Identity) | Select-Object id, login
    if ($oktaUser) {
      Invoke-OktaAPI -Endpoint "users/$($oktaUser.id)/appLinks" | Select-Object AppName, Label, Hidden, @{n='login';e={$oktaUser.login}}
    }
  }
}