---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Disable-OktaDashboardFooter

## SYNOPSIS
Disables (hides) the end-user footer on the Okta dashboard.

## SYNTAX

```
Disable-OktaDashboardFooter [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function sends a request to the Okta API to hide the customizable
footer that can be displayed on the end-user dashboard.
It effectively sets the preference to not show this footer.

## EXAMPLES

### EXAMPLE 1
```
Disable-OktaDashboardFooter
```

# This command will attempt to hide the end-user footer.
# If successful, the footer will no longer be visible to end users
# on their Okta dashboard.

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

## NOTES
This function relies on the \`Invoke-OktaAPI\` function to communicate
with the Okta API.
Ensure this function is available in your session.
You must have the necessary administrative permissions in your Okta
organization to modify organization preferences.
If an error occurs during the API call, it will be caught and displayed
using \`Write-Error\`.
To re-enable or show the footer, you would typically use corresponding
function \`Enable-OktaDashboardFooter\` which calls a different API endpoint
(e.g., 'org/preferences/showEndUserFooter').

## RELATED LINKS
