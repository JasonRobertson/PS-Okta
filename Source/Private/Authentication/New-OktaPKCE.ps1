function New-OktaPKCE {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [int]$Length = 128
    )

    if ($Length -gt 128 -or $Length -lt 43) {
        Write-Warning "Code Verifier length must be between 43 and 128 characters (inclusive)."
    }
    else {
    # From the ASCII Table in Decimal A-Z a-z 0-9
    $codeVerifier = -join (((48..57) * 4) + ((65..90) * 4) + ((97..122) * 4) | Get-Random -Count $length | ForEach-Object { [char]$_ })

    $hashAlgorithm  = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
    $hash           = $hashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($codeVerifier))
    $base64Hash     = [System.Convert]::ToBase64String($hash)
    $CodeChallenge  = $base64Hash.Replace('+', '-').Replace('/', '_').TrimEnd('=')

    [pscustomobject][ordered]@{
      CodeChallenge = $CodeChallenge
      CodeVerifier  = $codeVerifier
    }
  }
}