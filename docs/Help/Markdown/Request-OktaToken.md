---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Request-OktaToken

## SYNOPSIS
A private helper function to exchange an authorization code for access and refresh tokens.

## SYNTAX

```
Request-OktaToken [-Domain] <String> [-ClientID] <String> [-RedirectUri] <String> [-AuthorizationCode] <String>
 [-CodeVerifier] <String> [-OktaPreview] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function is used internally by Connect-Okta as part of the OAuth 2.0 Authorization Code with PKCE flow.
It makes a POST request to the Okta token endpoint, providing the necessary credentials and the authorization code
to receive the final tokens.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Domain
{{ Fill Domain Description }}

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

### -ClientID
{{ Fill ClientID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RedirectUri
{{ Fill RedirectUri Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AuthorizationCode
{{ Fill AuthorizationCode Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CodeVerifier
{{ Fill CodeVerifier Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -OktaPreview
{{ Fill OktaPreview Description }}

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

### [string]$Domain
### [string]$ClientID
### [string]$RedirectUri
### [string]$AuthorizationCode
### [string]$CodeVerifier
### [switch]$OktaPreview
## OUTPUTS

### [pscustomobject] - The token response object from Okta, containing access_token, refresh_token, etc.
## NOTES

## RELATED LINKS
