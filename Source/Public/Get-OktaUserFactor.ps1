function Get-OktaUserFactor {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(Mandatory, ValueFromPipeline=$true)]
    [alias('id')]
    [string[]]$Identity,
    [ValidateSet('CUSTOM','DUO','FIDO','GOOGLE','OKTA','RSA','SYMANTEC','YUBICO')]
    $FactorType
  )
  begin {
    $oktaAPI        = [hashtable]::new()
    $oktaAPI.Method = 'GET'
    $oktaAPI.Body   = $body
    $oktaAPI.All    = $all


  }
  process {
    foreach ($userID in $identity) {
      $id = (Invoke-OktaAPI -EndPoint users/$userID).id
      $oktaAPI.Endpoint = "users/$id/factors"
      Invoke-OktaAPI @oktaAPI
    }
  }
  end {
    [system.gc]::Collect();
  }
}