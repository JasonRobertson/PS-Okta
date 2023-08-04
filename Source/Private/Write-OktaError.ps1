function Write-OktaError {
  param (
    [parameter(Mandatory)]
    $Message
  )
  $errorRecord = [System.Management.Automation.ErrorRecord]::new(
    [Exception]::new($message),
    'ErrorID',
    [System.Management.Automation.ErrorCategory]::NotSpecified,
    'Okta'
  )
  $pscmdlet.ThrowTerminatingError($errorRecord)
}