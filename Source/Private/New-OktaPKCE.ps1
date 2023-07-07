Function New-OktaPKCE {
  [cmdletbinding()]
  param(
    [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
    [int]$Length = 128
  )

  if ($length -gt 128 -or $length -lt 43) {
    Write-Warning "Must be of 43 to 128 characters in length (inclusive)."
  }
  else {
    # From the ASCII Table in Decimal A-Z a-z 0-9
    $codeVerifier = -join (((48..57) * 4) + ((65..90) * 4) + ((97..122) * 4) | Get-Random -Count $length | ForEach-Object { [char]$_ })

    $hashAlgorithm  = [System.Security.Cryptography.HashAlgorithm]::Create('sha256')
    $hash           = $hashAlgorithm.ComputeHash([System.Text.Encoding]::UTF8.GetBytes($codeVerifier))
    $base64Hash     = [System.Convert]::ToBase64String($hash)
    $CodeChallenge  = $base64Hash.Substring(0, 43).Replace("/","_").Replace("+","-").Replace("=","")

    [pscustomobject][ordered]@{
      CodeChallenge = $CodeChallenge
      CodeVerifier  = $codeVerifier
    }
  }
}