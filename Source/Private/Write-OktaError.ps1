function Write-OktaError {
  param (
    [parameter(Mandatory)]
    $Message
  )
  [System.Management.Automation.ErrorRecord]::new(
    [Exception]::new($message),
    'ErrorID',
    [System.Management.Automation.ErrorCategory]::NotSpecified,
    'Okta'
  )
}