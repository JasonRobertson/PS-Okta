---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Remove-OktaEmailDomain

## SYNOPSIS
Removes an Okta email domain.

## SYNTAX

```
Remove-OktaEmailDomain [-Identity] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function allows you to remove an existing custom email domain from
your Okta organization.
It requires the Identity of the email domain to
be removed.
The function will first attempt to resolve the full email
domain ID from the provided identity.

## EXAMPLES

### EXAMPLE 1
```
# Remove an email domain by its ID
Remove-OktaEmailDomain -Identity "eml1bjs08b3e3IuYf1d7"
```

### EXAMPLE 2
```
# Remove an email domain by its associated domain name
Remove-OktaEmailDomain -Identity "example.com"
```

## PARAMETERS

### -Identity
(Mandatory) The ID or name of the Okta email domain to be removed.
This function will use Get-OktaEmailDomain to resolve the actual ID.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
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
This function relies on external \`Get-OktaEmailDomain\`, \`Invoke-OktaAPI\`,
and \`Write-OktaError\` functions.
It handles errors by catching exceptions
and \`Write-OktaError\` functions.
Ensure these functions are available
in your PowerShell session.
Ensure you have the necessary permissions in Okta to delete email domains.

## RELATED LINKS
