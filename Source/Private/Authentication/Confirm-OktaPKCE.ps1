function Confirm-OktaPKCE {
  [CmdletBinding()]
  param (
    [Parameter()]
    [string]$CodeVerifier
  )
  if ($codeVerifier.Length -gt 128 -or $codeVerifier.Length -lt 43) {
    Write-Warning "Code Verifier length must be of 43 to 128 characters in length (inclusive)."
  }
  else {
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