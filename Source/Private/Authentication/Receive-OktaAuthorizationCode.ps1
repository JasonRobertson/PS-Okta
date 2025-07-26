<#
.SYNOPSIS
  A private helper function that starts a temporary local web server to listen for the OAuth 2.0 callback from Okta.
.DESCRIPTION
  This function is used internally by Connect-Okta during the interactive OAuth 2.0 flow. It binds to a localhost port,
  waits for a single incoming request, and captures the query string parameters (like 'code', 'state', or 'error')
  returned by Okta after user authentication. It then sends a simple HTML response to the browser to close the loop.
.OUTPUTS
  [pscustomobject] - An object containing the query string parameters from the Okta callback.
#>
function Receive-OktaAuthorizationCode {
  [CmdletBinding()]
  [OutputType([pscustomobject])]
  param (
    [Parameter(Mandatory)]
    [string]$RedirectUri
  )

  if (-not ([System.Net.HttpListener]::IsSupported)) {
    throw "HttpListener is not supported on this platform, cannot perform interactive login."
  }

  $listener = New-Object System.Net.HttpListener
  $listener.Prefixes.Add($RedirectUri)
  $timeout = New-TimeSpan -Seconds 90
  $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

  try {
    $listener.Start()
    Write-Verbose "Listening for authentication redirect on $RedirectUri (Timeout: $($timeout.TotalSeconds) seconds)..."

    # This loop robustly waits for requests, ignoring irrelevant ones (like for /favicon.ico)
    # until the correct callback is received or the overall timeout is reached.
    while ($stopwatch.Elapsed -lt $timeout) {
      $remainingTime = $timeout - $stopwatch.Elapsed
      if ($remainingTime.TotalMilliseconds -le 0) { break }

      # Asynchronously wait for a request to come in
      $asyncResult = $listener.BeginGetContext($null, $null)

      # Wait on the handle for the remaining time or until a request comes in
      if ($asyncResult.AsyncWaitHandle.WaitOne($remainingTime)) {
        $context = $listener.EndGetContext($asyncResult)
        $request = $context.Request

        # We only care about the callback to the root path that contains a 'state' parameter.
        # Ignore other requests like the browser's automatic call for /favicon.ico
        if ($request.Url.AbsolutePath -eq '/' -and $request.QueryString.AllKeys.Contains('state')) {
          # This is the correct callback. Process it and exit the loop.
          $q = $request.QueryString
          $result = [PSCustomObject]@{
            Code             = $q['code']
            State            = $q['state']
            Error            = $q['error']
            ErrorDescription = $q['error_description']
          }

          # Send a user-friendly response to the browser
          $response = $context.Response
          $response.StatusCode = 200
          $response.ContentType = 'text/html'
          $message = if ($result.Code) {
            # On success, show a confirmation and attempt to auto-close the tab. This removes the URL with the auth code from view.
            @"
<html><head><title>Authentication Success</title><style>body{font-family:sans-serif;text-align:center;padding-top:50px;color:#333}h1{color:#28a745}p.subtle{color:#6c757d;font-size:small}</style></head>
<body><h1>Authentication Successful!</h1><p>You can now close this browser tab and return to your PowerShell terminal.</p><p class="subtle">This tab will attempt to close automatically in 3 seconds.</p><script>setTimeout(function(){window.close()},3000);</script></body></html>
"@
          }
          else {
            # On failure, show the error and attempt to auto-close the tab after a longer delay to allow the user to read the message.
            $encodedError = $result.ErrorDescription | ForEach-Object { [System.Net.WebUtility]::HtmlEncode($_) }
            @"
<html><head><title>Authentication Failed</title><style>body{font-family:sans-serif;text-align:center;padding-top:50px;color:#333}h1{color:#dc3545}p.error{color:#721c24;background-color:#f8d7da;border:1px solid #f5c6cb;padding:10px;border-radius:5px}p.subtle{color:#6c757d;font-size:small}</style></head>
<body><h1>Authentication Failed</h1><p class="error">An error occurred: $encodedError</p><p>Please return to your PowerShell terminal for more details.</p><p class="subtle">This tab will attempt to close automatically in 15 seconds.</p><script>setTimeout(function(){window.close()},15000);</script></body></html>
"@
          }
          $buffer = [System.Text.Encoding]::UTF8.GetBytes($message)
          $response.ContentLength64 = $buffer.Length
          $response.OutputStream.Write($buffer, 0, $buffer.Length)
          $response.OutputStream.Close()

          return $result
        }
        else {
          # This is an irrelevant request (e.g., favicon). Close it and continue waiting.
          $context.Response.StatusCode = 404
          $context.Response.Close()
          # Continue the loop to wait for the next request
        }
      }
      else {
        # WaitOne timed out
        break
      }
    }

    # If the loop finishes, it means we timed out without receiving the correct callback.
    return $null
  }
  catch {
    throw "The local HTTP listener failed: $_"
  }
  finally {
    if ($listener -and $listener.IsListening) {
      $listener.Stop()
    }
    if ($listener) {
      $listener.Close()
    }
  }
}