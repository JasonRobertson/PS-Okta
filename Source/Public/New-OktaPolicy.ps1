function New-OktaPolicy {
  [CmdletBinding()]
  param(
    [ValidateSet('Authorization Server Policy','Access Policy','IDP Discovery','MFA Enroll','Okta Sign On','Password','Profile Enrollment')]
    [Parameter(Mandatory,Position=0)]
    [string]$Type,
    [parameter(Mandatory,Position=1)]
    [string]$Name,
    [string]$Description,
    [int]$Priority = 0,
    [ValidateSet('Active','Inactive')]
    [string]$Status='Active'    
  )
  process {
    $oktaAPI                  = [hashtable]::new()
    $oktaAPI.Method           = 'POST'
    $oktaAPI.Endpoint         = 'policies'
    $oktaAPI.Body             = [hashtable]::new()
    $oktaAPI.Body.conditions  = [hashtable]::new()
    $oktaAPI.Body.description = $description
    $oktaAPI.Body.name        = $name
    $oktaAPI.Body.priority    = $priority
    $oktaAPI.Body.status      = $status.ToUpper()
    $oktaAPI.Body.system      = $true
    $oktaAPI.Body.type        = switch -Wildcard ($type) {
                                  Authorization* {$type.Replace(' ','')}
                                  default        {$type.Replace(' ','_').ToUpper()}
                                }
    Try {
      Write-Verbose $($oktaAPI.Body | ConvertTo-Json)
      Invoke-OktaAPI @oktaAPI
    }
    catch {
      Write-Error $PSItem.Exception.Message
    }
  }
}