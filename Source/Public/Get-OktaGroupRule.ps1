function Get-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName ='Default')]
  param (
    [parameter(ParameterSetName='Identity')]
    [string]$Identity,
    [ValidateRange(1,200)]
    [int]$Limit = 50,
    [switch]$MapGroupName,
    [switch]$All
  )
  
  $oktaApi              = [hashtable]::new()
  $oktaApi.All          = $all
  $oktaApi.Body         = [hashtable]::new()
  $oktaAPI.Body.limit   = $limit
  $oktaAPI.Body.expand  = if ($mapGroupName) {'groupIdToGroupNameMap'}
  $oktaAPI.Body.search  = $Identity
  $oktaApi.Endpoint     = "groups/rules"
  
  $response = (Invoke-OktaAPI @oktaApi)

  foreach ($groupRule in $response) {
    $assingedToGroups = switch ($MapGroupName) {
      False { $groupRule.actions.assignUserToGroups.groupIds }
      True  { 
        foreach ($groupID in $groupRule.actions.assignUserToGroups.groupIds){
          -join ($groupRule._embedded.groupIdToGroupNameMap.$($groupID), ' [', $groupID,']')
        }
      }
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