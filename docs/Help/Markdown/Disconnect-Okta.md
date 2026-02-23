---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Disconnect-Okta

## SYNOPSIS
Disconnects the current Okta API session.

## SYNTAX

```
Disconnect-Okta
```

## DESCRIPTION
This function removes the active Okta API connection variable from the
script scope, effectively disconnecting your PowerShell session from Okta.
If no active session is found, it issues a warning.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

## INPUTS

## OUTPUTS

## NOTES
This function manages a script-scoped variable named \`$script:connectionOkta\`.
It's designed to clean up the authentication token or session information
established by a corresponding \`Connect-Okta\` function (not shown here).
If a session cannot be gracefully disconnected, it suggests closing the
terminal.

## RELATED LINKS
