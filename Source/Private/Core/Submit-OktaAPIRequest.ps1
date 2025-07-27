<#
.SYNOPSIS
  A private helper to execute an API request with rate-limit handling.
.DESCRIPTION
  This function takes a pre-built hashtable of parameters for Invoke-RestMethod and executes it.
  It encapsulates the entire retry loop and rate-limit handling logic, including parsing the
  'X-Rate-Limit-Reset' header for intelligent backoff.
.PARAMETER RestMethodParameters
  A hashtable containing all the parameters to be splatted to Invoke-RestMethod.
.OUTPUTS
  The result from the Invoke-RestMethod call.
#>
function Submit-OktaAPIRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [hashtable]$RestMethodParameters
    )

    $maxRetries = 3
    for ($retryCount = 1; $retryCount -le $maxRetries; $retryCount++) {
        try {
            # The actual API call happens here. Return the raw result to the calling function.
            return Invoke-RestMethod @RestMethodParameters
        }
        catch {
            if ($_.Exception.Response -and $_.Exception.Response.StatusCode -eq 429) {
                if ($retryCount -eq $maxRetries) {
                    Write-Error "Okta API rate limit exceeded. Maximum retries ($maxRetries) reached. Failing."
                    $PSCmdlet.ThrowTerminatingError($_)
                }

                $responseHeaders = $_.Exception.Response.Headers
                $secondsToWait = 0
                $resetHeader = $responseHeaders.'X-Rate-Limit-Reset'
                $resetTimestamp = 0
                if ($resetHeader -and [long]::TryParse($resetHeader, [ref]$resetTimestamp)) {
                    $resetTime = [datetimeoffset]::FromUnixTimeSeconds($resetTimestamp).UtcDateTime
                    $secondsToWait = ($resetTime - [DateTime]::UtcNow).TotalSeconds
                }
                else {
                    if ($resetHeader) { Write-Verbose "The 'X-Rate-Limit-Reset' header contained an invalid value: '$resetHeader'. Falling back to exponential backoff." }
                    $secondsToWait = [math]::Pow(2, $retryCount)
                }

                if ($secondsToWait -le 0) { $secondsToWait = 1 }
                Write-Warning "Okta API rate limit hit. Retrying in $([math]::Round($secondsToWait, 0)) seconds... (Attempt $retryCount of $maxRetries)"
                Start-Sleep -Seconds $secondsToWait
            }
            else {
                $PSCmdlet.ThrowTerminatingError($_)
            }
        }
    }
}