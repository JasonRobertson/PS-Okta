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

  # --- RATE LIMIT HANDLING & RETRY LOGIC ---
  $maxRetries = 3
  for ($retryCount = 1; $retryCount -le $maxRetries; $retryCount++) {
    try {
      # Pipe the response directly to Select-Object to handle both single objects and arrays correctly.
      return Invoke-RestMethod @restMethod | Select-Object -ExcludeProperty _links
    }
    catch {
      # Check for the specific rate limit status code (429)
      if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 429) {
        if ($retryCount -eq $maxRetries) {
          Write-Error "Okta API rate limit exceeded. Maximum retries ($maxRetries) reached. Failing."
          $pscmdlet.ThrowTerminatingError($_) # Throw the last error
        }

        $headers = $_.Exception.Response.Headers
        $secondsToWait = 0

        # Okta provides a 'X-Rate-Limit-Reset' header with a Unix epoch timestamp.
        if ($headers.'X-Rate-Limit-Reset') {
          $resetTime = [datetimeoffset]::FromUnixTimeSeconds([long]$headers.'X-Rate-Limit-Reset').UtcDateTime
          $secondsToWait = ($resetTime - [DateTime]::UtcNow).TotalSeconds
        }
        else {
          # Fallback to exponential backoff if the header is missing for some reason.
          $secondsToWait = [math]::Pow(2, $retryCount)
        }

        # Ensure we wait at least 1 second, even if the reset time has just passed.
        if ($secondsToWait -le 0) { $secondsToWait = 1 }

        Write-Warning "Okta API rate limit hit. Retrying in $([math]::Round($secondsToWait, 0)) seconds... (Attempt $retryCount of $maxRetries)"
        Start-Sleep -Seconds $secondsToWait
      }
      else {
        # For any other error, re-throw it immediately without retrying.
        $pscmdlet.ThrowTerminatingError($_)
      }
    }
  }
}