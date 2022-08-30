function Get-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName ='RuleName')]
  param (
    [parameter(ParameterSetName='RuleID')]
    [string]$RuleID,
    #[switch]$Search,
    [parameter(ParameterSetName='RuleName')]
    [string]$RuleName,
    [ValidateSet('ACTIVE','INACTIVE')]
    [string]$Status,
    [ValidateRange(1,300)]
    [int]$Limit = 50,
    [switch]$MapGroupName,
    [switch]$All
  )
  begin {
    #region Static Variables
    #Verify the connection has been established
    $oktaUrl = Test-OktaConnection
    #region Build the headers
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion
    #region Build the body of the web request
    Write-Verbose 'Build the body of the web request'
    $body         = [hashtable]::new()
    $body.limit   = switch ($All) {
                      True  {200}
                      False {$Limit}
                    }
    switch ($MapGroupName){
      True {$body.expand  = 'groupIdToGroupNameMap'}
    }
    #If statements build for the body properties Status and Search for Group name
    if ($status)
      { $body.filter = "status=$Status" }
    if ($ruleName)
      { $body.search = $ruleName }

    #endregion
    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = Switch($PSCmdlet.ParameterSetName){
                                    RuleName   { "$oktaURL/v1/groups/rules"}
                                    RuleID     { "$oktaURL/v1/groups/rules/$ruleID"}
                                  }
    $webRequest.Body            = $body
    $webRequest.Method          = 'GET'
    $webRequest.Headers         = $headers
    $webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    Try {
      $output = switch ($All) {
        false {
          Try {
            $response = Invoke-WebRequest @webRequest
            ConvertFrom-Json $response.Content
          }
          Catch [System.Net.WebResponse] {
            Write-Warning $PSItem.Exception.Message
          }
        }
        true {
          do{
            $response = Invoke-WebRequest @webRequest
            $webRequest.Uri = $response.RelationLink.next #RelationLink is the recommended approach for pagination from Okta.
            $webRequest.Remove('Body')
            ConvertFrom-Json $response.Content
          } until (-not $response.RelationLink.next)
        }
      }
    }
    Catch {
      Write-Error $PSItem.Exception.Message
      Write-Output $PSItem.Exception.ItemName
    }
    if ($output){
      foreach ($groupRule in $output){
        $assingedToGroups = switch ($MapGroupName) {
          True  {
            foreach ($groupID in $groupRule.actions.assignUserToGroups.groupIds){
              -join ($groupRule._embedded.groupIdToGroupNameMap.$($groupID), ' (', $groupID,')')
            }
          }
          False { $groupRule.actions.assignUserToGroups.groupIds }
        }
        [PSCustomObject][Ordered]@{
          Name              = $groupRule.Name
          ID                = $groupRule.ID
          Status            = $groupRule.Status
          Conditions        = $groupRule.conditions.expression.value
          AssignedToGroups  = $assingedToGroups
          ExcludeUsers      = $groupRule.conditions.people.users.exclude
          ExcludeGroups     = $groupRule.conditions.people.groups.exclude
          Created           = $groupRule.Created
          LastUpdated       = $groupRule.LastUpdated
        }
      }
    }
  }
  end {
    [system.gc]::Collect();
  }
}