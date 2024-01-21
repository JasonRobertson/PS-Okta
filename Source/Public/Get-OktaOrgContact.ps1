function Get-OktaOrgContact {
  [CmdletBinding()]
  param()
  foreach ($type in $('Technical','Billing')){
    $userID = (Invoke-OktaAPI -Endpoint org/contacts/$type).userID
    Get-OktaUser -Identity $userID | Select-Object @{n='contactType';e={$type}}, DisplayName, Title, Department, Email, PrimaryPhone, Status
  }
}