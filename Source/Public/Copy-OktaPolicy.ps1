function Copy-OktaPolicy {
  [CmdletBinding()]
  param(
    [parameter(ValueFromPipeLine, position=0)]
    [string]$Identity
  )
  process {
    $oktaAPI.[hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = "policies/$Identity/clone"
    try {
      Invoke-OktaAPI @oktaAPI
    }
    catch {
      $PSItem.Exception.Message
    }
  }
}