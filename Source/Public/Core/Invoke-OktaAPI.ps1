function Invoke-OktaAPI {
  [CmdletBinding()]
  Param(
    [ValidateSet('GET', 'PATCH', 'POST', 'PUT', 'DELETE')]
    [string]$Method='GET',
    [Parameter(Mandatory)]
    [string]$Endpoint,
    [object]$Body,
    [switch]$All
  )

  # --- Start of Consolidated Logic ---

  # 1. Ensure the connection is active and refresh the token if necessary.
  # This helper function returns a valid authorization header string.
  $authorizationHeader = Confirm-OktaConnection

  # 2. Prepare the request
  $body = switch ($Method -match '^GET|DELETE$' ) {
    True  {$Body}
    False {$Body | ConvertTo-Json -Depth 100}
  }

  # 3. Build the request parameters
  $headers                 = [hashtable]::new()
  $headers.Accept          = 'application/json'
  $headers.Authorization   = $authorizationHeader

  $restMethod                     = [hashtable]::new()
  $restMethod.Uri                 = "$($script:connectionOkta.Uri)/$Endpoint"
  $restMethod.Body                = $body
  $restMethod.Method              = $Method
  $restMethod.ContentType         = 'application/json'
  $restMethod.Headers             = $headers
  $restMethod.FollowRelLink       = $All

  # 4. Delegate the actual web request and rate-limit handling to a dedicated helper.
  $result = Submit-OktaAPIRequest -RestMethodParameters $restMethod
  
  # 5. Enumerate the final result to ensure correct pipeline output.
  if ($null -ne $result) {
    foreach ($item in $result) {
      $item | Select-Object -ExcludeProperty _links
    }
  }
}