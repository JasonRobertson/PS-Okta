<#
  .Synopsis
    Connect-Okta is used to establish the connection to the Organization Okta.
  .DESCRIPTION
    Connect-Okta is used to establish the connection to the Organization Okta. Requires an API Token generated within Okta Admin Portal.
  .EXAMPLE
    PS C:\> Connect-Okta -Domain Okta -ApiToken 1aQ_ATswwGVThisisnotvalidjXxvQ5qP4EYPS8AZ8S
    Connected successfully to Okta

    Organization : Okta
    Requestor    : John Snow
  .EXAMPLE
    PS C:\> Connect-Okta -Domain Okta -ApiToken 1aQ_ATswwGVhisisnotvalidjXxvQ5qP4EYPS8AZ8S
    Connected successfully to Okta

    Organization : Okta
    Requestor    : John Snow
  .EXAMPLE
    PS C:\Nutanix> Connect-Okta

    cmdlet Connect-Okta at command pipeline position 1
    Supply values for the following parameters:
    Domain: Okta
    ApiToken: 1aQ_ATswwGVhisisnotvalidjXxvQ5qP4EYPS8AZ8S
    Connected successfully to Okta

    Organization : Okta
    Requestor    : John Snow
  .INPUTS
    None
  .OUTPUTS
    None
  .NOTES
    No other cmdlets will work without having run Connect-Okta first.
  .COMPONENT
  .ROLE
    To verify Okta Org and API Token are valid.
  .FUNCTIONALITY
    Sends a query to Okta to verify the Okta Org and API Token provider are valid and caches Okta Url, API Token, and
    within the powershell session to run other commands in the Okta module.
#>
function Connect-Okta {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    [string]$Domain,
    [parameter(Mandatory)]
    [string]$ApiToken,
    [switch]$Preview
  )
  begin {
    $uri = switch ($Preview){
      true  {-join ('https://',$Domain,'.oktapreview.com/api/v1')}
      false {-join ('https://',$Domain,'.okta.com/api/v1')}
    }

    $headers               = [hashtable]::new()
    $headers.Accept        = 'application/json'
    $headers.Authorization = "SSWS $ApiToken"

    $restMethod             = [hashtable]::new()
    $restMethod.Method      = 'GET'
    $restMethod.Uri         = "$uri/users/me"
    $restMethod.Headers     = $headers
    $restMethod.ContentTYpe = 'application/json'
  }
  process {
    try {
      $requestor = Invoke-RestMethod @restMethod
      If ($requestor){
        $status = switch ($Preview) {
          True  { "Connected successfully to $domain Okta Preview" }
          False { "Connected successfully to $domain Okta" }
        }

        Write-Host -ForegroundColor Green $status

        [PSCustomObject][ordered]@{
          Organization = $domain
          Requestor    = $requestor.profile.login
        } | Format-List

        #Global Scope is necesary to provide the value for other commands
        $global:connectionOkta = [pscustomobject][ordered]@{
          URI       = $uri
          ApiToken  = ConvertTo-SecureString -AsPlainText -Force -String "SSWS $ApiToken"
          ActorID   = $requestor.Id
        }
      }
    }
    catch {
      Write-Host -ForegroundColor Red    "Failed to connect to Okta"
      Write-Host -ForegroundColor Yellow "Verify the ApiToken and Domain are valid."
    }
  }
  end {
    Remove-Variable apiToken
  }
}