# Private helper function for handling the legacy API Token connection flow.
function New-OktaConnectionApiToken {
    [CmdletBinding()]
    param(
        [parameter(Mandatory)]
        [pscredential]$ApiToken,
        [parameter(Mandatory)]
        [string]$BaseUri
    )

    Write-Verbose "Connecting using legacy API Token."
    $headers = @{
        Accept        = 'application/json'
        Authorization = "SSWS $($apiToken.GetNetworkCredential().password)"
    }
    # Test connection and fetch user data in one call to reduce latency
    Write-Verbose "Testing API Token and fetching user details from /api/v1/users/me..."
    $requestor = Invoke-RestMethod -Method GET -Uri "$BaseUri/api/v1/users/me" -Headers $headers -ErrorAction Stop

    Write-Verbose "API Token is valid. Returning user object."
    return $requestor
}