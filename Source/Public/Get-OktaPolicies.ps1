function Get-OktaPolicies {
  [cmdletbinding()]
  param(
    [validateSet('Access Policy','IDP Discovery','MFA Enroll','Okta Sign On','Password','Profile Enrollment')]
    [parameter(Mandatory)]
    [string]$Type
  )

  $oktaAPI = [hashtable]::new()
  $oktaAPI.Body = [hashtable]::new()
  $oktaAPI.Body.type = switch ($type) {
    'Access Policy'       {'ACCESS_POLICY'}
    'IDP Discovery'       {'IDP_DISCOVERY'}
    'MFA Enroll'          {'MFA_ENROLL'}
    'Okta Sign On'        {'OKTA_SIGN_ON'}
    'Password'            {'PASSWORD'}
    'Profile Enrollment'  {'PROFILE_ENROLLMENT'}
  }
  $oktaAPI.Endpoint = 'policies'

  try {
    Invoke-OktaAPI @oktaAPI
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
  
}