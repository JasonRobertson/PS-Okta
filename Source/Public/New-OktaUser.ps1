function New-OktaUser {
  [cmdletbinding()]
  param(
    #Unique identifier for the user
    [parameter(Mandatory)]
    [ValidateLength(1,100)]
    [string]$UserName,
    #Given name of the user
    [parameter(Mandatory)]
    [ValidateLength(1,50)]
    [string]$FirstName,
    #Family name of the user
    [parameter(Mandatory)]
    [ValidateLength(1,50)]
    [string]$LastName,
    #Middle name(s) of the user
    [string]$MiddleName,
    #Casual way to address the user in real life
    [string]$NickName,
    #Name of the user, suitable for display to end users
    [parameter(Mandatory)]
    [string]$DisplayName,
    #Primary email address of the user
    [ValidateLength(5,100)]
    [parameter(Mandatory)]
    [string]$Email,
    #SecondEmail address of the user typically used for account recovery
    [string]$SecondEmail,
    #URL of the user's online profile (for example: a web page)
    [string]$ProfileUrl,
    #User's preferred written or spoken languages
    [string]$PreferredLanguage,
    #Used to describe the organization to user relationship such as "Employee" or "Contractor"
    [string]$UserType,
    #Name of the user's organization
    [string]$Organization,
    #User's title, such as "Vice President"
    [string]$Title,
    #Name of the user's division
    [string]$Division,
    #Name of the user's department
    [string]$Department,
    #Name of a cost center assigned to user
    [string]$CostCenter,
    #Organization or company assigned unique identifier for the user
    [string]$EmployeeNumber,
    #Primary phone number of the user such as home number
    [ValidateLength(1,100)]
    [string]$PrimaryPhone,
    #Mobile phone number of the user
    [string]$MobilePhone,
    #Full street address component of the user's address
    [string]$StreetAddress,
    #City or locality component of the user's address (locality)
    [string]$City,
    #State or region component of the user's address (region)
    [string]$State,
    #ZIP code or postal code component of the user's address (postalCode)
    [string]$ZipCode,
    #Country name component of the user's address (country)
    [string]$CountryCode,
    #Honorific prefix(es) of the user, or title in most Western languages
    [string]$honorificPrefix,
    #Honorific suffix(es) of the user
    [string]$honorificSuffix,
    #Mailing address component of the user's address
    [string]$PostAddress,
    #DisplayName of the user's manager
    [string]$Manager,
    #id of a user's manager
    [string]$ManagerID,
    #custom attributes created by the organization
    $CustomAttribute = $null
  )
  $body    = [hashtable]::new()
  $payload = [hashtable]::new()

  switch ($PSBoundParameters.Keys) {
    UserName            {$payload.login             = $userName}
    FirstName           {$payload.firstName         = $firstName}
    LastName            {$payload.lastName          = $lastName}
    MiddleName          {$payload.middleName        = $middleName}
    NickName            {$payload.nickName          = $nickName}
    DisplayName         {$payload.displayName       = $displayName}
    Email               {$payload.email             = $email}
    SecondEmail         {$payload.secondEmail       = $secondEmail}
    ProfileUrl          {$payload.profileUrl        = $profileUrl}
    PreferredLanguage   {$payload.preferredLanguage = $preferredLanguage}
    UserType            {$payload.userType          = $userType}
    Organization        {$payload.organization      = $organization}
    Title               {$payload.title             = $title}
    Division            {$payload.division          = $division}
    Department          {$payload.department        = $department}
    CostCenter          {$payload.costCenter        = $costCenter}
    EmployeeNumber      {$payload.employeeNumber    = $employeeNumber}
    MobilePhone         {$payload.mobilePhone       = $mobilePhone}
    StreetAddress       {$payload.streetAddress     = $streetAddress}
    City                {$payload.city              = $city}
    State               {$payload.state             = $state}
    ZipCode             {$payload.zipCode           = $ZipCode}
    CountryCode         {$payload.countryCode       = $countryCode}
    honorificPrefix     {$payload.honorificPrefix   = $honorificPrefix}
    honorificSuffix     {$payload.honorificSuffix   = $honorificSuffix}
    PostAddress         {$payload.postAddress       = $postAddress}
    Manager             {$payload.manager           = $manager}
    ManagerID           {$payload.managerId         = $managerID}
  }
  $body.profile = switch ($null -eq $CustomAttribute) {
                    True    {$payload}
                    False   {$payload + $customAttribute}
                  }

  $oktaAPI          = [hashtable]::new()
  $oktaAPI.Body     = $body
  $oktaAPI.Method   = 'POST'
  $oktaAPI.Endpoint = "/users"
  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $_.Exception.Message
  }
  
}