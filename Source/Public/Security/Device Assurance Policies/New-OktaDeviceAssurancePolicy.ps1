function New-OktaDeviceAssurancePolicy {
  [cmdletbinding()]
  param(
    [paramter(Mandatory, Position=0)]
    [string]$Name,
    [paramter(Mandatory, Position=1)]
    [ValidateSet('ByDateTime','ByDuration')]
    $GracePeriodType,
    [paramter(Mandatory, Position=0)]
    [validateset('Android','iOS','macOS','Windows')]
    [string]$Platform,
    $MinimumVersion,
    [switch]$DiskEncryptionType,
    $JailBreak,
    $ScreenLockType
  )
  
}