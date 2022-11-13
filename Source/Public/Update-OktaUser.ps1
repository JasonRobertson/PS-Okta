function Update-OktaUser {
  <#
  .SYNOPSIS
  Update-OktaUser command is used to update an Okta Users profile properties
  #>
  [CmdletBinding(DefaultParameterSetName='')]
  param (
    [parameter(Position=0, Mandatory=$true, ValueFromPipeline=$true)]
    $Identity,
    #Unique identifier for the user
    [string]$UserName,
    #Given name of the user
    [string]$FirstName,
    #Family name of the user
    [string]$LastName,
    #Middle name(s) of the user
    [string]$MiddleName,
    #Casual way to address the user in real life
    [string]$NickName,
    #Name of the user, suitable for display to end users
    [string]$DisplayName,
    #Primary email address of the user
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
    [string]$ManagerID
  )
  begin {
    try {
      $oktaUrl = Test-OktaConnection
      $oktaUserID = (Get-OktaUser -Identity $Identity -ErrorAction STOP).id
      #region Build the headers
      $headers                  = [hashtable]::new()
      $headers.Accept           = 'application/json'
      $headers.Authorization    = Convert-OktaAPIToken
      #endregion
      $payload = [hashtable]::new()
      if ($UserName)          {$payload.login = $userName}
      if ($FirstName)         {$payload.firstName = $firstName}
      if ($LastName)          {$payload.lastName = $lastName}
      if ($MiddleName)        {$payload.middleName = $middleName}
      if ($NickName)          {$payload.nickName = $nickName}
      if ($DisplayName)       {$payload.displayName = $displayName}
      if ($Email)             {$payload.email = $email}
      if ($SecondEmail)       {$payload.secondEmail = $secondEmail}
      if ($ProfileUrl)        {$payload.profileUrl = $profileUrl}
      if ($PreferredLanguage) {$payload.preferredLanguage = $preferredLanguage}
      if ($UserType)          {$payload.userType = $userType}
      if ($Organization)      {$payload.organization = $organization}
      if ($Title)             {$payload.title = $title}
      if ($Division)          {$payload.division = $division}
      if ($Department)        {$payload.department = $department}
      if ($CostCenter)        {$payload.costCenter = $costCenter}
      if ($EmployeeNumber)    {$payload.employeeNumber = $employeeNumber}
      if ($MobilePhone)       {$payload.mobilePhone = $mobilePhone}
      if ($StreetAddress)     {$payload.streetAddress = $streetAddress}
      if ($City)              {$payload.city = $city}
      if ($State)             {$payload.state = $state}
      if ($ZipCode)           {$payload.zipCode = zipCode}
      if ($CountryCode)       {$payload.countryCode = countryCode}
      if ($honorificPrefix)   {$payload.honorificPrefix = $honorificPrefix}
      if ($honorificSuffix)   {$payload.honorificSuffix = $honorificSuffix}
      if ($PostAddress)       {$payload.postAddress = $postAddress}
      if ($Manager)           {$payload.manager = $manager}
      if ($ManagerID)         {$payload.managerId = $managerID}
      #region Build the body of the web request
      $body         = [hashtable]::new()
      $body.profile = $payload
      #endregion
      #region Build the Web Request
      $restMethod                 = [hashtable]::new()
      $restMethod.Uri             = "$oktaUrl/users/$oktaUserID"
      $restMethod.Body            = $body | ConvertTo-Json
      $restMethod.Method          = 'POST'
      $restMethod.Headers         = $headers
      $restMethod.ContentType     = 'application/json'
      #endregion
    }
    catch {
      $pscmdlet.ThrowTerminatingError($PSItem)
    }
  }
  process {
    try {
      (Invoke-RestMethod @restMethod).profile
    }
    catch{
      $pscmdlet.ThrowTerminatingError($PSItem)
    }
  }
  end {
    [system.gc]::Collect();
  }
}