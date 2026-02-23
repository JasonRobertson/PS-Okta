---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# New-OktaOIDCApplication

## SYNOPSIS
Helps create and configure a new Service (M2M) OIDC application in Okta for use with this module.

## SYNTAX

```
New-OktaOIDCApplication [-AppName <String>] [-RedirectUris <String[]>] [-Register] [-AssignToCurrentUser]
 [-AssignToGroup <String>] [-AssignToEveryone] [-AssignAdminRole <String[]>] [-Scope <String[]>]
 [-ProgressAction <ActionPreference>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
This function helps an administrator create and configure the necessary Service (Machine-to-Machine) OpenID Connect application in their Okta organization.
This type of application is required for unattended automation using the Client Credentials flow (\`Connect-Okta -ClientCredentials\`).

Default Mode (Informational):
Provides a step-by-step guide for manually creating the application in the Okta Admin Console.

Register Mode (-Register):
Uses the Okta API to automatically create the application.
This requires an active connection to Okta using an API Token with sufficient permissions (e.g., App Admin).
The function will output the generated Client ID and Client Secret, which are needed to connect.

## EXAMPLES

### EXAMPLE 1
```
New-OktaOIDCApplication
```

--- Manual Service Application Setup Guide ---
This guide will walk you through creating a Service (M2M) OIDC application in Okta...
...

This example shows the default behavior, which is to display the informational guide for manually creating the application.

### EXAMPLE 2
```
# This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
PS C:\> New-OktaOIDCApplication -AppName "PowerShell Automation" -Register -AssignAdminRole "Read-only Administrator"
```

Successfully created application 'PowerShell Automation'.
Your new Client ID is: 0oa123456789abcdefg

********************************** IMPORTANT **********************************
Your Client Secret is: aBcDeFg...xyz
This is the ONLY time the secret will be displayed.
Store it securely now.
*******************************************************************************

Successfully granted the following API scopes:
 - okta.apps.read
 - okta.orgs.read
 - ...
(other read-only scopes)
Use it to connect: $secret = Read-Host -AsSecureString; Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg' -ClientSecret $secret

PS C:\\\> New-OktaOIDCApplication -AppName "User Management Tool" -Register -Scope $userAdminScopes

Successfully created application 'User Management Tool'.
Your new Client ID is: 0oa...
Successfully granted the following API scopes:
 - okta.users.read
 - okta.users.manage
Successfully assigned application to the current user (admin@example.com).

This example creates an application and grants it specific permissions for user administration, overriding the default scopes.

### EXAMPLE 3
```
# This example creates an application and grants it all the scopes of a Group Administrator.
PS C:\> New-OktaOIDCApplication -AppName "Group Management Tool" -Register -AssignAdminRole "Group Administrator"
```

Successfully created application 'Group Management Tool'.
Your new Client ID is: 0oa...
Successfully granted the following API scopes:
 - okta.groups.manage
 - okta.users.read
Successfully assigned application to the current user (admin@example.com).

This example uses a role-based scope assignment, which is simpler than specifying individual scopes.

### EXAMPLE 4
```
# This example creates an application with all the permissions of a Super Administrator.
PS C:\> New-OktaOIDCApplication -AppName "Super Admin Tool" -Register -AssignAdminRole "Super Administrator"
```

Successfully created application 'Super Admin Tool'.
Your new Client ID is: 0oa...
Successfully granted the following API scopes:
 - okta.apps.manage
 - okta.apps.read
 ...
Successfully assigned application to the current user (admin@example.com).

This example grants all available API scopes to the application, which is useful for a tool that needs full administrative access.

## PARAMETERS

### -AppName
The name for the new OIDC application in Okta.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: PS-Okta PowerShell Module
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectUris
{{ Fill RedirectUris Description }}

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @('http://localhost:8080/')
Accept pipeline input: False
Accept wildcard characters: False
```

### -Register
A switch to enable Automatic Registration Mode, which will create the application via the API.

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

### -AssignToCurrentUser
{{ Fill AssignToCurrentUser Description }}

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

### -AssignToGroup
{{ Fill AssignToGroup Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AssignToEveryone
{{ Fill AssignToEveryone Description }}

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

### -AssignAdminRole
A convenience parameter to grant all the API scopes associated with a default Okta admin role (e.g., 'Group Administrator').
These are added to the base scopes required for the module to function.
This parameter supports tab-completion.
For a detailed description of what each role can do, see the Okta documentation: https://help.okta.com/oie/en-us/content/topics/security/administrators-admin-comparison.htm

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scope
Specifies API scopes to grant to the new service application.
The base scopes 'okta.apps.read' and 'okta.orgs.read' are always included to ensure \`Connect-Okta\` can function.
You can provide a list of any valid Okta API scopes.
This parameter supports tab-completion for all available scopes.
For a detailed description of each scope, see the Okta documentation: https://developer.okta.com/docs/api/oauth2/#okta-admin-management

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
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

## NOTES
The automatic registration mode requires a connection established with \`Connect-Okta -ApiToken ...\`.
The resulting Client ID is used with \`Connect-Okta -ClientID ...\`.

## RELATED LINKS
