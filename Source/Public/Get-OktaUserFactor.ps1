function Get-OktaUserFactor {
  [CmdletBinding(DefaultParameterSetName='Default')]
  param (
    # Identity is used to fetch a user by id, login, or login shortname if the short name is unambiguous
    [parameter(Mandatory, ValueFromPipeline=$true)]
    [alias('id')]
    [string[]]$Identity
  )
  begin {
    $oktaAPI        = [hashtable]::new()
    $oktaAPI.Method = 'GET'
    $oktaAPI.Body   = $body
    $oktaAPI.All    = $all
  }
  process {
    foreach ($id in $(Get-OktaUser -Identity $Identity).id) {
      $oktaAPI.Endpoint = "users/$id/factors"
      Invoke-OktaAPI @oktaAPI
    }
  }
  end {
    [system.gc]::Collect();
  }
}