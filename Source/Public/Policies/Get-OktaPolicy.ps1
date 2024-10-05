function Get-OktaPolicy {
  [cmdletbinding(DefaultParameterSetName='List')]
  param(
    [parameter(Position=0,ValueFromPipeline,ParameterSetName='Identity')]
    [string]$Identity,
    [validateSet('Access Policy','IDP Discovery','MFA Enroll','Okta Sign On','Password','Profile Enrollment')]
    [parameter(Mandatory,Position=0,ParameterSetName='List')]
    [string]$Type,
    [validateSet('Active','Inactive')]
    [parameter(Position=1,ParameterSetName='List')]
    [string]$Status
  )
  begin {          
    $oktaAPI      = [hashtable]::new()
    $oktaAPI.Body = [hashtable]::new()
  }
  process {
    switch ($PSCmdlet.ParameterSetName) {
      Identity { 
        $oktaAPI.Endpoint = "policies/$identity" 
      }
      List {
        $oktaAPI.Endpoint = 'policies'
        switch ($PSBoundParameters.Keys) {
          Type    {$oktaAPI.Body.type   = $type.Replace(' ','_').ToUpper()}
          Status  {$oktaAPI.Body.status = $Status.ToUpper()}
        }
      }
    }
    try {
      Invoke-OktaAPI @oktaAPI
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}