function Set-OktaOrganization {
  [CmdletBinding()]
  param(
    [string]$Address1,
    [string]$Address2,
    [string]$City,
    [string]$State,
    [string]$PostalCode,
    [string]$Country,
    [string]$CompanyName,
    [string]$EndUserSupportHelpURL,
    [string]$PhoneNumber,
    [string]$SupportPhoneNumber,
    [string]$Website
  )
  $body = [hashtable]::new()
  switch ($PSBoundParameters.Keys) {
    Address1              {$body.address1               = $address1}
    Address2              {$body.address2               = $address2}
    City                  {$body.city                   = $city}
    State                 {$body.state                  = $state}
    PostalCode            {$body.postalCode             = $postalCode}
    Country               {$body.country                = $country}
    CompanyName           {$body.companyName            = $company}
    EndUserSupportHelpURL {$body.endUserSupportHelpURL  = $endUserSupportHelpURL}
    PhoneNumber           {$body.phoneNumber            = $phoneNumber}
    SupportPhoneNumber    {$body.supportPhoneNumber     = $supportPhoneNumber}
    Website               {$body.website                = $website}
  }

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Body     = $body
  $oktaAPI.Method   = 'POST'
  $oktaAPI.EndPoint = 'org'
  Invoke-OktaAPI @oktaAPI 
}