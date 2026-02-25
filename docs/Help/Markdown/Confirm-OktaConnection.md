---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Confirm-OktaConnection

## SYNOPSIS
A private helper to ensure the Okta connection is active and the token is valid.

## SYNTAX

```
Confirm-OktaConnection [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function checks for an active session.
If the session is OAuth-based and the access token
is expired or nearing expiration, it automatically attempts to refresh it using the stored
refresh token.
It returns a valid authorization header for use in API calls.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

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

### [string] - A valid 'Authorization' header string (e.g., "Bearer ...").
## NOTES

## RELATED LINKS
