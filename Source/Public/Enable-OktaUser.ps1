function Enable-OktaUser {
  [CmdletBinding(DefaultParameterSetName='UserID')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(ParameterSetName='UserID')]
    [string]$Identity
    # ApiToken is a required field and can be created in Okta instance https://{domain}.okta.com/admin/access/api/tokens
  )
  begin {
    #region Static Variables

    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'GET'
    $oktaAPI.Body     = $body
    $oktaAPI.All      = $all
    $oktaAPI.Endpoint = $endPoint


    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = "$oktaUrl/users/$oktaUserID/lifecycle/activate?sendEmail=false"
    $webRequest.Body            = $body
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    
  }
  end{}
}