---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaFeature

## SYNOPSIS
Retrieves a list of features and their status for your Okta organization.

## SYNTAX

```
Get-OktaFeature [[-Identity] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function queries the Okta Features API to list all available features, their status (ENABLED/DISABLED), and their stage (EA/BETA/GA).
This is useful for programmatically determining which Okta products (like Identity Governance) are enabled in your tenant before attempting to use their associated APIs or scopes.

## EXAMPLES

### EXAMPLE 1
```
Get-OktaFeature
```

id                                      name                                    status
--                                      ----                                    ------
okta_identity_governance                Okta Identity Governance                ENABLED
reports_password_health                 Password Health Report                  ENABLED
custom_url_domain                       Custom URL Domain                       ENABLED
...

Lists all features available in the Okta organization and their current status.

### EXAMPLE 2
```
Get-OktaFeature -Identity '*governance*'
```

id                                      name                                    status
--                                      ----                                    ------
okta_identity_governance                Okta Identity Governance                ENABLED

Finds a specific feature by name, in this case, checking if Okta Identity Governance (OIG) is enabled.

## PARAMETERS

### -Identity
The name or ID of a specific feature to retrieve.
Wildcards (*) are supported for pattern matching.
If omitted, all features are returned.

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
Requires an API connection with at least 'okta.features.read' permission, which is included in the 'Read-only Administrator' role.

## RELATED LINKS
