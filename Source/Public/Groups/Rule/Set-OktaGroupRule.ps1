function Set-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName='Users')]
  param (
    [parameter( Mandatory)]
    [string]$Identity,
    [ValidateSet('Add','Remove')]
    [string]$Action,
    [parameter(ParameterSetName='Conditions')]
    [string]$Conditions,
    #[string[]]$ExcludeGroups, #Not Supported by Okta at this time.
    [parameter(ParameterSetName='Users')]
    [string[]]$ExcludeUser,
    [parameter(ParameterSetName='AssignGroups')]
    [string[]]$AssignToGroup,
    [switch]$BypassLookup
  )
  begin {
    Write-Verbose "Querying details of the Okta Group Rule"
    $oktaGroupRule  = Get-OktaGroupRule -Identity $Identity
    if ($oktaGroupRule.Status -eq 'Active') {
      throw "Okta Group Rule can only be updated when Status is INACTIVE. Disable the Group Rule and try again."
    }
    #region Verify if UserID is valid
    if ($excludeUser) {
      Write-Verbose "ByPassLookup Present :$ByBassLookup"
      foreach ($user in $excludeUser) {
        $userID = switch ($BypassLookup) {
          True  {$user}
          False {(Get-OktaUser -Identity $user).id}
        }
        switch ($action) {
          Add     { $oktaGroupRule.excludeUsers.add($userID) | Out-Null }
          Remove  { $oktaGroupRule.excludeUsers.remove($userID) | Out-Null }
        }
      }
    }
    #endregion
    #region Verify GroupID are valid for AssignedToGroups
    if ($assignToGroup) {
      foreach ($group in $assignToGroup) {
        $groupID = (Get-OktaGroup -Identity $group).id
        switch ($Action) {
          Add     { $oktaGroupRule.assignedToGroups.Add($groupID) | Out-Null }
          Remove  { $oktaGroupRule.assignedToGroups.Remove($groupID) | Out-Null }
        }
      }
    }
    #endregion
  }
  process {
    $body                                     = [hashtable]::new()
    $body.type                                = 'group_rule'
    $body.name                                = $oktagrouprule.Name
    $body.status                              = $oktaGroupRule.Status

    $body.actions                             = [hashtable]::new()
    $body.actions.assignUserToGroups          = [hashtable]::new()
    $body.actions.assignUserToGroups.groupIds = {$oktaGroupRule.assignedToGroups | Select-Object -Unique}.invoke()

    $body.conditions                          = [hashtable]::new()
    $body.conditions.people                   = [hashtable]::new()
    $body.conditions.people.users             = [hashtable]::new()
    $body.conditions.people.users.exclude     = {$oktaGroupRule.excludeUsers | Select-Object -Unique}.invoke()
    $body.conditions.people.groups            = [hashtable]::new()
    $body.conditions.people.groups.exclude    = {$oktaGroupRule.excludeGroups | Select-Object -Unique}.invoke()

    $body.conditions.expression               = [hashtable]::new()
    $body.conditions.expression.value         = $oktaGroupRule.Conditions
    $body.conditions.expression.type          = 'urn:okta:expression:1.0'

    $oktaAPI          = [hashtable]::new()
    $oktaAPI.Body     = $body
    $oktaAPI.Method   = 'PUT'
    $oktaAPI.Endpoint = "groups/rules/$($oktaGroupRule.id)"

    $global:response = (Invoke-OktaAPI @oktaApi)

    if ($response) {
      foreach ($groupRule in $response) {
        $assingedToGroups = switch ($MapGroupName) {
          False { $groupRule.actions.assignUserToGroups.groupIds }
          True  {
            foreach ($groupID in $groupRule.actions.assignUserToGroups.groupIds){
              -join ($groupRule._embedded.groupIdToGroupNameMap.$($groupID))
            }
          }
        }
        [PSCustomObject][Ordered]@{
          name              = $groupRule.Name
          id                = $groupRule.ID
          status            = $groupRule.Status
          conditions        = $groupRule.conditions.expression.value
          assignedToGroups  = {$groupRule.actions.assignUserToGroups.groupIds}.invoke()
          excludeUsers      = {$groupRule.conditions.people.users.exclude}.invoke()
          excludeGroups     = {$groupRule.conditions.people.groups.exclude}.invoke()
          lastUpdated       = $groupRule.LastUpdated
        }
      }
    }
  }
  end {}
}