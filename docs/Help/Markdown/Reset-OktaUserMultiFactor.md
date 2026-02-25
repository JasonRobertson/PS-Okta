---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Reset-OktaUserMultiFactor

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

### Reset (Default)
```
Reset-OktaUserMultiFactor -Identity <String> [-All] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### Provider
```
Reset-OktaUserMultiFactor -Identity <String> -Provider <String> [-RemoveRecoveryEnrollment]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
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

### -All
{{ Fill All Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Reset
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Identity
{{ Fill Identity Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Provider
{{ Fill Provider Description }}

```yaml
Type: String
Parameter Sets: Provider
Aliases:
Accepted values: CUSTOM, DUO, FIDO, GOOGLE, OKTA, RSA, SYMANTEC, YUBICO

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RemoveRecoveryEnrollment
{{ Fill RemoveRecoveryEnrollment Description }}

```yaml
Type: SwitchParameter
Parameter Sets: Provider
Aliases:

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

### None
## OUTPUTS

### System.Object
## NOTES

## RELATED LINKS
