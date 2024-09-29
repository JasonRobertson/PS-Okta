function Get-OktaSystemLogs {
  [CmdletBinding()]
  param(
    [datetime]$From = (Get-Date -Format o).ToUniversalTime(),
    [datetime]$To,
    [string]$Target,
    [string]$Actor,
    [validateSet()]
    [string[]]$EventType,
    [string]$Result,
    [ValidateRange(0,1000)]
    [int32]$limit = 100,
    [ValidateSet('ASCENDING','DESCENDING')]
    [string]$Sort = 'ASCENDING'
    )
  process {
    try {
      $body = [hashtable]::new()
      if ($to) {$body.until = (Get-date $to -Format o)}
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}