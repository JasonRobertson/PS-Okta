---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaEmailDomain

## SYNOPSIS
Retrieves information about Okta email domains.

## SYNTAX

```
Get-OktaEmailDomain [[-Identity] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function interacts with the Okta API to fetch details about the email
domains configured in your Okta organization.
It's primarily used to list
all email domains.

## EXAMPLES

### EXAMPLE 1
```
Get-OktaEmailDomain
Retrieves a list of all configured Okta email domains.
```

## PARAMETERS

### -Identity
This parameter is included for consistency with other \`Get-Okta*\` functions
but is currently not utilized by the underlying Okta API for this endpoint.
Providing a value for \`Identity\` will not filter the results.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
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
This function relies on an external \`Invoke-OktaAPI\` function to handle the
actual API calls and \`Write-OktaError\` for standardized error reporting.
Ensure these functions are available in your PowerShell session.

## RELATED LINKS
