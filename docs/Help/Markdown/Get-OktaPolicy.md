---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaPolicy

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### List (Default)
```
Get-OktaPolicy [-Type] <String> [[-Status] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Identity
```
Get-OktaPolicy [[-Identity] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
{{ Fill in the Description }}

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -Identity
{{ Fill Identity Description }}

```yaml
Type: String
Parameter Sets: Identity
Aliases:

Required: False
Position: 0
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Status
{{ Fill Status Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:
Accepted values: Active, Inactive

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
{{ Fill Type Description }}

```yaml
Type: String
Parameter Sets: List
Aliases:
Accepted values: Access Policy, IDP Discovery, MFA Enroll, Okta Sign On, Password, Profile Enrollment

Required: True
Position: 0
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

### System.String
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
