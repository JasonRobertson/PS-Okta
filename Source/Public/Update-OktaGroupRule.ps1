function Update-OktaGroupRule {
  [CmdletBinding(DefaultParameterSetName='Users')]
  param (
    [parameter( Mandatory)]
    [string]$RuleID,
    [ValidateSet('Add','Remove')]
    [string]$Action,
    [parameter(ParameterSetName='Conditions')]
    [string]$Conditions,
    #[string[]]$ExcludeGroups, #Not Supported by Okta at this time.
    [parameter(ParameterSetName='Users')]
    [string[]]$ExcludeUsers,
    [parameter(ParameterSetName='AssignGroups')]
    [string[]]$AssignToGroups,
    [Switch]$BypassLookup
  )
  begin {
    #region Okta Domain, used to verify if its production or development (OktaPreview)
    $oktaUrl = Test-OktaConnection
    #endregion
    #region Get-OktaGroup Rule, Used to verify the RuleID is valid.
    Try {
      Write-Verbose "Querying details of the Okta Group Rule"
      $oktaGroupRule  = Get-OktaGroupRule -RuleID $ID
    }
    catch {
      Write-Verbose $PSItem.exception.message
      Throw "Cannot find the Okta Group Rule based on the ID: $ID"
    }
    If ($oktaGroupRule.Status -eq 'Active') {
      Throw "Okta Group Rule can only be updated when Status is INACTIVE. Deactivate the Group Rule and try again."
    }
    #endregion

    # Create a generic list to add/remove entries from ExcludeUsers & ExcludeGroups
    $oktaExcludeUsers     = { $oktaGroupRule.ExcludeUsers     }.invoke()
    #$oktaExcludeGroups    = { $oktaGroupRule.ExcludeGroups    }.invoke()
    $oktaAssignedToGroups = { $oktaGroupRule.AssignedToGroups }.invoke()

    #region Verify if UserID is valid
    if ($excludeUsers) {
      Write-Verbose "ByPassLookup Present :$ByBassLookup"
      foreach ($user in $excludeUsers) {
        $userID = switch ($BypassLookup) {
          True  {$user}
          False {(Get-OktaUser @oktaDetails -Identity $user).id}
        }
        switch ($action) {
          Add     {
            Write-Verbose "Adding $user to the Exclude User List"
            $oktaExcludeUsers.add($userID) | Out-Null
          }
          Remove  {
            Write-Verbose "Removing $user from the Exclude User List"
            $oktaExcludeUsers.remove($userID)  | Out-Null
          }
        }
      }
    }
    $peopleExclude = ($oktaExcludeUsers | ConvertTo-Json).Replace('[','').Replace(']','')
    #endregion

    #region Verify GroupID are valid for AssignedToGroups
    if ($assignedToGroups) {
      foreach ($group in $assignedToGroups) {
        $groupID = (Get-OktaGroup @oktaDetails -GroupID $group).id
        switch ($Action) {
          Add     {
            $oktaAssignedToGroups.Add($groupID)
            Write-Verbose "Adding $group to the Exclude User List"
          }
          Remove  {
            $oktaAssignedToGroups.Remove($groupID)
            Write-Verbose "Removing $group to the Exclude User List"
          }
        }
      }
    }
    $groupIds = ($oktaAssignedToGroups | ConvertTo-Json).Replace('[','').Replace(']','')
    #>

    #endregion

    #region Build the headers
    $headers                  = [hashtable]::new()
    $headers.Accept           = 'application/json'
    $headers.Authorization    = Convert-OktaAPIToken
    #endregion

    #region Build the body of the web request
    Write-Verbose 'Build the body of the web request'
    $body = @"
{
  "type": "group_rule",
  "id" : "$($oktaGroupRule.ID)",
  "status": "$($oktaGroupRule.Status)",
  "name": "$($oktagrouprule.Name)",
  "conditions": {
    "people": {
      "users": {
        "exclude": [$peopleExclude]
      },
      "groups": {
        "exclude": []
      }
    },
    "expression": {
      "value": "$($oktaGroupRule.Conditions.Replace('"','\"'))",
      "type": "urn:okta:expression:1.0"
    }
  },
  "actions": {
    "assignUserToGroups": {
      "groupIds": [$groupids]
    }
  }
}
"@
    #endregion

    #region Build the Web Request
    $webRequest                 = [hashtable]::new()
    $webRequest.Uri             = -join ($oktaURL,"/api/v1/groups/rules/$($oktaGroupRule.ID)")
    $webRequest.Body            = $body
    $webRequest.Method          = 'PUT'
    $webRequest.Headers         = $headers
    $webRequest.ContentType     = 'application/json'
    #$webRequest.UseBasicParsing = $true
    #endregion
  }
  process {
    Try {
      Write-Verbose "Note: Only rules with status='INACTIVE' can be updated."
      Write-Debug $webRequest.Body
      $response = Invoke-WebRequest @webRequest -SkipHttpErrorCheck
      switch -Wildcard ($response.StatusCode){
        40* {
          $response = $response.Content | ConvertFrom-Json
          Switch -Wildcard ($response.errorSummary) {
            *Conditions {
                Write-Error $response.errorCauses.errorSummary
            }
            default {
              Write-Error $response.errorSummary
            }
          }
        }
        200 {
          $response.Content | ConvertFrom-Json
        }
      }
    }
    Catch {
      $PSCmdlet.ThrowTerminatingError($PSItem)
    }
  }
  end {
    [system.gc]::Collect();
  }
}