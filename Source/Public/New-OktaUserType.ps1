function New-OktaUserType {
  [CmdletBinding()]
  param(
    [parameter(Mandatory)]
    #The name of the User Type. The name must start with A-Z or a-z and contain only A-Z, a-z, 0-9, or underscore (_) characters. This value becomes read-only after creation and can't be updated.
    [ValidateScript({
      if ($_ -notmatch '^[A-Za-z0-9_]+$') {
        $message = "The Name paramter value must start with A-Z or a-z and contain only A-Z, a-z, 0-9, or underscore (_) characters. This value becomes read-only after creation and can't be updated."
        $errorRecord = [System.Management.Automation.ErrorRecord]::new(
          [Exception]::new($message),
          'ErrorID',
          [System.Management.Automation.ErrorCategory]::NotSpecified,
          'Okta'
        )
        $pscmdlet.ThrowTerminatingError($errorRecord)
      }
      else {$true}
    })]
    [string]$Name,
    #The human-readable name of the User Type
    [parameter(Mandatory)]
    [string]$DisplayName,
    #The human-readable name of the User Type
    [string]$Description
  )
  begin {
  }
  process {
    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Method   = 'POST'
    $oktaAPI.EndPoint = 'meta/types/user'

    $oktaAPI.Body             = [hashtable]::new()
    $oktaAPI.Body.name        = $Name
    $oktaAPI.Body.displayName = $DisplayName
    $oktaAPI.Body.description = $Description
    
    Invoke-OktaAPI @oktaAPI
  }
  end {}
}