function Enable-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName ='RuleID')]
  param (
    [parameter(ParameterSetName='RuleID')]
    [string]$RuleID
  )
  begin {
    Write-Verbose "BEGIN Block: Start"
    #region Static Variables
    #oktaPreview switch used to define either okta.com or oktapreview.com
    $oktaUrl = Test-OktaConnection

    #endregion
    #region Build the headers for the web request
    Write-Verbose 'Build the headers for the web request'
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion
    #region Build the body of the web request
    Write-Verbose 'Build the body of the web request'
    $body         = [hashtable]::new()
    #endregion
    #region Build the Web Request
    Write-Verbose 'Building the web request.'
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = "$oktaURL/api/v1/groups/rules/$RuleID/lifecycle/activate"
    $webRequest.Body            = $body
    $webRequest.Method          = 'POST'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    Write-Verbose 'Send Web Query: Start'
    $response = Invoke-WebRequest @webRequest
    switch ($response.StatusCode) {
      204 {
        Write-Verbose "Send Web Query: Success"
        Write-Output "Enabled $RuleID successfully"
        Write-Verbose "Send Web Query: End"
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}