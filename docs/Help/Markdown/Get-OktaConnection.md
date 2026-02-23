---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaConnection

## SYNOPSIS
Displays details about the current, active connection to an Okta organization.

## SYNTAX

```
Get-OktaConnection [-IncludeOktaScopes] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves the stored session object and displays key information about the connection,
including the connection type (OAuth 2.0 or legacy API Token), user details, and standard OIDC scopes.
To view the specific Okta administrative scopes for an OAuth 2.0 connection, use the -IncludeOktaScopes switch.

## EXAMPLES

### EXAMPLE 1
```
Get-OktaConnection
```

CompanyName    : My Company
Domain         : my-org
URI            : https://my-org.okta.com/api/v1
User           : admin@example.com
UserID         : 00u123...
ConnectionType : OAuth 2.0
ClientName     : PS-Okta PowerShell Module
ClientID       : 0oa456...
Scopes         : - email
                 - offline_access
                 - openid
                 - profile
OktaScopes     : 2 (use -IncludeOktaScopes to view)

Displays a summary of the current active session, indicating that additional Okta-specific scopes are present.

### EXAMPLE 2
```
Get-OktaConnection -IncludeOktaScopes
```

...
Scopes         : - email
                 - offline_access
                 - openid
                 - profile
OktaScopes     : - okta.orgs.read
                 - okta.users.read.self

Displays the full list of both standard and Okta-specific API scopes for the current session, separated into their own properties.

## PARAMETERS

### -IncludeOktaScopes
When specified for an OAuth 2.0 connection, this switch includes the detailed list of Okta administrative scopes (e.g., 'okta.users.read') in the output.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
{{ Fill ProgressAction Description }}

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject
## NOTES
This command does not make any API calls itself, except for an optional call to retrieve the Client Name for OAuth connections.

## RELATED LINKS
