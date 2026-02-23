function New-OktaDeviceAssurancePolicy {
  [cmdletbinding()]
  param(
    [parameter(Mandatory, Position=0)]
    [string]$Name,
    [parameter(Mandatory, Position=1)]
    [ValidateSet('ByDateTime','ByDuration')]
    $GracePeriodType,
    [parameter(Mandatory, Position=2)]
    [validateset('Android','iOS','macOS','Windows')]
    [string]$Platform,
    $MinimumVersion,
    [switch]$DiskEncryptionType,
    $JailBreak,
    $ScreenLockType
  )
  
}