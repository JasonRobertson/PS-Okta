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

    $endPoint = switch ($PSCmdlet.ParameterSetName) {
      default  {"users/$identity/factors"}
    }
  }
  process {
    foreach ($id in $(Get-OktaUser -Identity $Identity).id) {
      $oktaAPI.Endpoint = $endPoint
      Invoke-OktaAPI @oktaAPI
    }
  }
  end {
    [system.gc]::Collect();
  }
}