---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Submit-OktaAPIRequest

## SYNOPSIS
A private helper to execute an API request with rate-limit handling.

## SYNTAX

```
Submit-OktaAPIRequest [-RestMethodParameters] <Hashtable> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function takes a pre-built hashtable of parameters for Invoke-RestMethod and executes it.
It encapsulates the entire retry loop and rate-limit handling logic, including parsing the
'X-Rate-Limit-Reset' header for intelligent backoff.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

### -RestMethodParameters
A hashtable containing all the parameters to be splatted to Invoke-RestMethod.

```yaml
Type: Hashtable
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

### The result from the Invoke-RestMethod call.
## NOTES

## RELATED LINKS
