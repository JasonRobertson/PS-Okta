---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# New-OktaSessionObject

## SYNOPSIS
A private helper to build the final, rich session object after a successful authentication.

## SYNTAX

```
New-OktaSessionObject [-AuthResult] <Object> [-BaseUri] <String> [-Domain] <String> [-Preview] <Boolean>
 [-ParameterSetName] <String> [[-ClientID] <String>] [[-ApiToken] <PSCredential>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function takes the result of an authentication attempt (either a token response or a user object)
and performs the necessary API calls to fetch additional user and organization details.
It then
assembles and returns the complete, standardized connection object used by the module.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -AuthResult
{{ Fill AuthResult Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -BaseUri
{{ Fill BaseUri Description }}

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

### -Domain
{{ Fill Domain Description }}

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

### -Preview
{{ Fill Preview Description }}

```yaml
Type: Boolean
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ParameterSetName
{{ Fill ParameterSetName Description }}

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

### -ClientID
{{ Fill ClientID Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiToken
{{ Fill ApiToken Description }}

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
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

### [pscustomobject] - The final, rich connection object.
## NOTES

## RELATED LINKS
