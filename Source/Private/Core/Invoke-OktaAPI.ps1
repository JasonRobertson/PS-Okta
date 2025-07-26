function Invoke-OktaAPI {
  [CmdletBinding()]
  Param(
    [ValidateSet('GET', 'PATCH', 'POST', 'PUT', 'DELETE')]
    [string]$Method='GET',
    [Parameter(Mandatory)]
    [string]$Endpoint,
    $Body,
    [switch]$All
  )
  #Verify the connection has been established
  if ($null -eq $script:connectionOkta) {
    throw "Not connected to Okta. Please run Connect-Okta first."
  }

  # --- AUTOMATIC TOKEN REFRESH LOGIC ---
  # Check if we are using OAuth and if the token is expired (or close to expiring, e.g., within 1 minute)
  if ($script:connectionOkta.Tokens -and [DateTime]::UtcNow -ge $script:connectionOkta.Tokens.AccessTokenExpiresAt.AddMinutes(-1)) {
    Write-Verbose "Access token expired or is expiring soon. Attempting to refresh..."
    try {
      $newTokens = Request-OktaRefreshToken -Domain $script:connectionOkta.Domain -ClientID $script:connectionOkta.ClientID -RefreshToken $script:connectionOkta.Tokens.refresh_token -OktaPreview:$script:connectionOkta.OktaPreview
      
      # Update the expiration time on the new token set
      $newTokens.AccessTokenExpiresAt = [DateTime]::UtcNow.AddSeconds($newTokens.expires_in)
      
      # IMPORTANT: The refresh token might be rotated. Always use the new one if provided.
      # If a new one isn't provided, the old one is still valid.
      if (-not $newTokens.refresh_token) {
        $newTokens.refresh_token = $script:connectionOkta.Tokens.refresh_token
      }

      # Atomically update the global connection object
      $script:connectionOkta.Tokens = $newTokens
      Write-Verbose "Token refresh successful."
    }
    catch {
      throw "Failed to refresh the access token. You may need to re-authenticate using Connect-Okta. Original error: $_"
    }
  }
  # --- END OF REFRESH LOGIC ---

  $oktaURI = $script:connectionOkta.Uri
  $authorizationHeader = if ($script:connectionOkta.Tokens) { "Bearer $($script:connectionOkta.Tokens.access_token)" } else { "SSWS $($script:connectionOkta.ApiToken.GetNetworkCredential().password)" }

  $body = switch ($Method -match '^GET|DELETE$' ) {
    True  {$body}
    False {$body | ConvertTo-Json -Depth 100}
  }

  $restMethod                       = [hashtable]::new()
  $restMethod.Uri                   = "$oktaURI/$endpoint"
  $restMethod.Body                  = $body
  $restMethod.Method                = $method
  $restMethod.ContentType           = 'application/json'
  $restMethod.Headers               = [hashtable]::new()
  $restMethod.Headers.Accept        = 'application/json'
  $restMethod.Headers.Authorization = $authorizationHeader
  $restMethod.FollowRelLink         = $all

  try {
    # Pipe the response directly to Select-Object to handle both single objects and arrays correctly.
    Invoke-RestMethod @restMethod | Select-Object -ExcludeProperty _links
  }
  catch {
    # Re-throw the original error record to preserve the full stack trace and details for easier debugging.
    $pscmdlet.ThrowTerminatingError($_)
  }
}