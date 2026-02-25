---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# New-OktaDeviceAssurancePolicy

## SYNOPSIS
{{ Fill in the Synopsis }}

## SYNTAX

```
New-OktaDeviceAssurancePolicy [-Name] <String> [-GracePeriodType] <Object> [-Platform] <String>
 [-MinimumVersion <Object>] [-DiskEncryptionType] [-JailBreak <Object>] [-ScreenLockType <Object>]
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

### -DiskEncryptionType
{{ Fill DiskEncryptionType Description }}

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -GracePeriodType
{{ Fill GracePeriodType Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:
Accepted values: ByDateTime, ByDuration

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -JailBreak
{{ Fill JailBreak Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MinimumVersion
{{ Fill MinimumVersion Description }}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Name
{{ Fill Name Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 0
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Platform
{{ Fill Platform Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:
Accepted values: Android, iOS, macOS, Windows

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScreenLockType
{{ Fill ScreenLockType Description }}

```yaml
Type: Object
Parameter Sets: (All)
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
