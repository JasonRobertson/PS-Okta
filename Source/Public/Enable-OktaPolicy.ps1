function Enable-OktaPolicy {
  [CmdletBinding()]
  param(
    [parameter(ValueFromPipeLine, position=0)]
    [string]$Identity
  )
  process {
    $oktaAPI.[hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.Endpoint = "policies/$Identity/lifecycle/activate"
    try {
      Invoke-OktaAPI @oktaAPI
    }
    catch {
      $PSItem.Exception.Message
    }
  }
}