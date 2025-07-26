<#
.SYNOPSIS
  A private helper function that returns a mapping of Okta Admin Role names to their corresponding API scopes.
.DESCRIPTION
  This function centralizes the data structure that defines which API scopes are associated with each standard
  Okta administrator role. It is used by New-OktaOIDCApplication to simplify role-based scope assignments.
.OUTPUTS
  [hashtable] - A hashtable where keys are role names and values are arrays of scope strings.
#>
function Get-OktaRoleScopeMap {
    return @{
        # Roles are sorted alphabetically for easy reference.
        # Scopes within each role are also sorted alphabetically.

        'API Access Management Administrator' = @(
            'okta.authorizationServers.manage',
            'okta.clients.manage'
        ) # Manages authorization servers, scopes, and clients

        'Application Administrator'           = @(
            'okta.apps.manage',
            'okta.groups.read',
            'okta.users.read'
        ) # Manages applications and their user assignments

        'Group Administrator'                 = @(
            'okta.groups.manage',
            'okta.users.read'
        ) # Manages groups and their memberships

        'Group Membership Administrator'      = @(
            'okta.groups.members.manage',
            'okta.groups.read',
            'okta.users.read'
        ) # Manages group memberships only

        'Help Desk Administrator'             = @(
            'okta.factors.manage',
            'okta.groups.read',
            'okta.sessions.manage',
            'okta.users.credentials.manage',
            'okta.users.read'
        ) # Resets passwords/MFA and unlocks users

        'Organizational Administrator'        = @(
            'okta.apps.manage',
            'okta.authenticators.manage',
            'okta.authorizationServers.manage',
            'okta.brands.manage',
            'okta.clients.manage',
            'okta.devices.manage',
            'okta.domains.manage',
            'okta.eventHooks.manage',
            'okta.factors.manage',
            'okta.groups.manage',
            'okta.idps.manage',
            'okta.inlineHooks.manage',
            'okta.networkZones.manage',
            'okta.policies.manage',
            'okta.profileMappings.manage',
            'okta.resourceSets.manage',
            'okta.schemas.manage',
            'okta.templates.manage',
            'okta.trustedOrigins.manage',
            'okta.users.manage',
            'okta.userTypes.manage'
        ) # Has wide-ranging permissions to manage the Okta organization, but cannot manage other administrators.

        'Read-only Administrator'             = @(
            'okta.administrators.read',
            'okta.apps.read',
            'okta.authenticators.read',
            'okta.authorizationServers.read',
            'okta.brands.read',
            'okta.clients.read',
            'okta.deviceAssurancePolicies.read',
            'okta.devices.read',
            'okta.domains.read',
            'okta.eventHooks.read',
            'okta.factors.read',
            'okta.groups.read',
            'okta.idps.read',
            'okta.inlineHooks.read',
            'okta.logs.read',
            'okta.networkZones.read',
            'okta.orgs.read',
            'okta.policies.read',
            'okta.profileMappings.read',
            'okta.resourceSets.read',
            'okta.schemas.read',
            'okta.templates.read',
            'okta.threatInsights.read',
            'okta.trustedOrigins.read',
            'okta.users.read',
            'okta.userTypes.read',
            'okta.workflows.read'
        ) # The 'Auditor' role; provides read-only access to most Okta features and logs.

        'Report Administrator'                = @(
            'okta.apps.read',
            'okta.groups.read',
            'okta.logs.read',
            'okta.users.read'
        ) # Views reports and system log

        'Super Administrator'                 = @(
            'okta.administrators.manage',
            'okta.administrators.read',
            'okta.apps.manage',
            'okta.apps.read',
            'okta.authenticators.manage',
            'okta.authenticators.read',
            'okta.authorizationServers.manage',
            'okta.authorizationServers.read',
            'okta.brands.manage',
            'okta.brands.read',
            'okta.clients.manage',
            'okta.clients.read',
            'okta.deviceAssurancePolicies.read',
            'okta.devices.manage',
            'okta.devices.read',
            'okta.domains.manage',
            'okta.domains.read',
            'okta.eventHooks.manage',
            'okta.eventHooks.read',
            'okta.factors.manage',
            'okta.factors.read',
            'okta.groups.manage',
            'okta.groups.members.manage',
            'okta.groups.read',
            'okta.idps.manage',
            'okta.idps.read',
            'okta.inlineHooks.manage',
            'okta.inlineHooks.read',
            'okta.logs.read',
            'okta.networkZones.manage',
            'okta.networkZones.read',
            'okta.orgs.read',
            'okta.policies.manage',
            'okta.policies.read',
            'okta.profileMappings.manage',
            'okta.profileMappings.read',
            'okta.resourceSets.manage',
            'okta.resourceSets.read',
            'okta.schemas.manage',
            'okta.schemas.read',
            'okta.sessions.manage',
            'okta.templates.manage',
            'okta.templates.read',
            'okta.threatInsights.read',
            'okta.trustedOrigins.manage',
            'okta.trustedOrigins.read',
            'okta.users.credentials.manage',
            'okta.users.manage',
            'okta.users.read',
            'okta.userTypes.manage',
            'okta.userTypes.read',
            'okta.workflows.read'
        ) # The highest-level administrator; can manage all aspects of the Okta organization, including other administrators.

        'User Administrator'                  = @(
            'okta.factors.manage',
            'okta.groups.manage',
            'okta.users.credentials.manage',
            'okta.users.manage'
        ) # Manages users, groups, and their credentials/factors. Per Okta docs, this role includes group management.
    }
}