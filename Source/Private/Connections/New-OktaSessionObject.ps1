<#
.SYNOPSIS
  A private helper to build the final, rich session object after a successful authentication.
.DESCRIPTION
  This function takes the result of an authentication attempt (either a token response or a user object)
  and performs the necessary API calls to fetch additional user and organization details. It then
  assembles and returns the complete, standardized connection object used by the module.
.OUTPUTS
  [pscustomobject] - The final, rich connection object.
#>
function New-OktaSessionObject {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [object]$AuthResult,
    [parameter(Mandatory)]
    [string]$BaseUri,
    [parameter(Mandatory)]
    [string]$Domain,
    [parameter(Mandatory)]
    [bool]$Preview,
    [parameter(Mandatory)]
    [string]$ParameterSetName,
    [string]$ClientID,
    [pscredential]$ApiToken
  )

  Write-Verbose "Fetching user and organization details to populate connection object."
  $authHeader = ''
  if ($ParameterSetName -in @('OAuth', 'ClientCredentials')) {
    $authHeader = "Bearer $($AuthResult.access_token)"
  }
  else { # ApiToken
    $authHeader = "SSWS $($apiToken.GetNetworkCredential().password)"
  }
  $commonHeaders = @{ Accept = 'application/json'; Authorization = $authHeader }

  $requestor = $null
  if ($ParameterSetName -eq 'ApiToken') {
    $requestor = $AuthResult
  }
  elseif ($ParameterSetName -eq 'ClientCredentials') {
    # For M2M auth, the "user" is the application itself. Fetch its details.
    Write-Verbose "Fetching application details for Client ID: $ClientID"
    $script:connectionOkta = [ordered]@{ Uri = $BaseUri }
    $appDetails = Invoke-OktaAPI -Method GET -Endpoint "api/v1/apps/$ClientID"
    $requestor = [pscustomobject]@{ Id = $appDetails.id; profile = @{ login = $appDetails.label } }
  } else { # OAuth
    # For user-based auth, fetch the user's details.
    Write-Verbose "Fetching user details from /api/v1/users/me."
    $script:connectionOkta = [ordered]@{ Uri = $BaseUri }
    $requestor = Invoke-OktaAPI -Method GET -Endpoint 'api/v1/users/me'
  }

  Write-Verbose "Fetching organization details from /api/v1/org."
  $script:connectionOkta = [ordered]@{ Uri = $BaseUri }
  $organization = Invoke-OktaAPI -Method GET -Endpoint 'api/v1/org'

  # Create the final, complete connection object with a defined order
  Write-Verbose "Updating connection object with user: $($requestor.profile.login) and company: $($organization.CompanyName)."
  $connectionObject = [ordered]@{
    CompanyName = $organization.CompanyName
    Domain      = $Domain
    URI         = "$BaseUri/api/v1"
    OktaPreview = $Preview
    User        = $requestor.profile.login
    UserID      = $requestor.Id
  }

  # Add authentication-specific properties which are not for display
  if ($ParameterSetName -in @('OAuth', 'ClientCredentials')) {
    $connectionObject.Tokens   = $AuthResult
    $connectionObject.ClientID = $ClientID
  } else {
    $connectionObject.ApiToken = $apiToken
  }
  
  return [pscustomobject]$connectionObject
}