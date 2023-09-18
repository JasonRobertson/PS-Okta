function Get-OktaOrgContact {
  [CmdletBinding()]
  param() 
  foreach ($type in $('Technical','Billing')){
    $userID = (Invoke-OktaAPI -Endpoint org/contacts/$type).userID
    $oktaUser = Get-OktaUser -Identity $userID

    $object             = [hashtable]::new()
    $object.ContactType = $type
    $object.ID          = $oktaUser.ID
    $object.Status      = $oktaUser.Status
    $object.User        = $oktaUser.DisplayName
    $object.Title       = 
    $object.PhoneNumber = $oktaUser.PhoneNumber
    $object.Email       = $oktaUser.Email
  
    $oktaUser | Select-Object @{n='contactType';e={$type}}, DisplayName, Department, Title, Status
  }
}