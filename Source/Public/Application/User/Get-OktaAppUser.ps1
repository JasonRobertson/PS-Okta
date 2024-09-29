function Get-OktaAppUser {
  [CmdletBinding()]
  param (
    [parameter(Mandatory)]
    [string]$Identity,
    [string]$User,
    [ValidateRange(1,500)]
    [int]$Limit=500,
    [switch]$All
  )
  try {
    $app = Get-OktaApp -Identity $identity

    if ($app.count -eq 1) {
      $oktaAPI            = [hashtable]::new()
      $oktaAPI.All        = $all
      $oktaAPI.Body       = [hashtable]::new()
      $oktaAPI.Body.q     = $user
      $oktaAPI.Body.limit = $limit
      $oktaAPI.Endpoint   = "apps/$identity/users"
      
      Invoke-OktaAPI @oktaAPI | Select-Object -ExpandProperty Credentials -ExcludeProperty Credentials | Select-Object -ExpandProperty Profile -ExcludeProperty Profile  
    }
    else {
      $oktaError = Write-OktaError {"$identity returned $($app.count) results","Use the application ID instead."}.invoke()
      $pscmdlet.ThrowTerminatingError($oktaError)
    }
  }
  catch {
    Write-Error $PSItem.Exception.Message
  }
}