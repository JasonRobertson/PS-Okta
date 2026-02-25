---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Receive-OktaAuthorizationCode

## SYNOPSIS
A private helper function that starts a temporary local web server to listen for the OAuth 2.0 callback from Okta.

## SYNTAX

```
Receive-OktaAuthorizationCode [-RedirectUri] <String> [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function is used internally by Connect-Okta during the interactive OAuth 2.0 flow.
It binds to a localhost port,
waits for a single incoming request, and captures the query string parameters (like 'code', 'state', or 'error')
returned by Okta after user authentication.
It then sends a simple HTML response to the browser to close the loop.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -RedirectUri
{{ Fill RedirectUri Description }}

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

### [pscustomobject] - An object containing the query string parameters from the Okta callback.
## NOTES

## RELATED LINKS
