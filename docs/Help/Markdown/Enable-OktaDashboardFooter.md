---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Enable-OktaDashboardFooter

## SYNOPSIS
Enables (shows) the end-user footer on the Okta dashboard.

## SYNTAX

```
Enable-OktaDashboardFooter [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function sends a request to the Okta API to show the customizable
footer that can be displayed on the end-user dashboard.
It effectively sets the preference to display this footer.

## EXAMPLES

### EXAMPLE 1
```
Enable-OktaDashboardFooter
```

# This command will attempt to show the end-user footer.
# If successful, the footer will become visible to end users
# on their Okta dashboard (assuming it has been configured with content).

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
using \`Write-OktaError\`.
To hide the footer, you would typically use a corresponding
function like \`Disable-OktaDashboardFooter\` which calls a different API endpoint
(e.g., 'org/preferences/hideEndUserFooter').

## RELATED LINKS
