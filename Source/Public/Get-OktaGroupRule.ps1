function Get-OktaGroupRule {
  [CmdletBinding()]
  param (
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

  if ($response) {
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
        name              = $groupRule.Name
        id                = $groupRule.ID
        status            = $groupRule.Status
        conditions        = $groupRule.conditions.expression.value
        assignedToGroups  = $assingedToGroups
        excludeUsers      = $groupRule.conditions.people.users.exclude
        excludeGroups     = $groupRule.conditions.people.groups.exclude
        created           = $groupRule.Created
        lastUpdated       = $groupRule.LastUpdated
      }
    }
  }
  else {
    Write-Warning "No Group Rule found with the keyword $identity"
  }
}