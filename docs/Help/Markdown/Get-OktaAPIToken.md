---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaAPIToken

## SYNOPSIS
Retrieves Okta API tokens for the currently authenticated user.

## SYNTAX

```
Get-OktaAPIToken [[-Identity] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function retrieves API tokens from the Okta organization that belong to the user associated with the current API Token connection.
It can retrieve a specific token by its ID, search for tokens by name, or list all tokens for the user.

## EXAMPLES

### EXAMPLE 1
```
# First, connect with an API Token. Note that OAuth connections cannot manage API tokens.
PS C:\> $cred = Get-Credential -Message "Enter your Okta API Token"
PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
PS C:\> Get-OktaAPIToken
```

Retrieves all API tokens belonging to the authenticated user.

### EXAMPLE 2
```
Get-OktaAPIToken -Identity '0oabc...'
```

Retrieves a single API token by its unique ID.

### EXAMPLE 3
```
Get-OktaAPIToken -Identity '*service*'
```

Searches for all API tokens belonging to the current user that have 'service' in their name.

## PARAMETERS

### -Identity
The ID or name of the API token to retrieve.
Wildcards (*) are supported for name searches.
If omitted, all tokens for the current user are returned.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByPropertyName)
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
This command requires an active Okta connection using a legacy API Token.
It cannot be used with an OAuth 2.0 connection.
The API token used for the connection must have permissions to read its own tokens.
A '403 Forbidden' error can occur if this is not the case, though this is rare.

## RELATED LINKS
