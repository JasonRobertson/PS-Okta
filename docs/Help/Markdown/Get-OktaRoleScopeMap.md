---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaRoleScopeMap

## SYNOPSIS
A private helper function that returns a mapping of Okta Admin Role names to their corresponding API scopes.

## SYNTAX

```
Get-OktaRoleScopeMap
```

## DESCRIPTION
This function centralizes the data structure that defines which API scopes are associated with each standard
Okta administrator role.
It is used by New-OktaOIDCApplication to simplify role-based scope assignments.

## EXAMPLES

### Example 1
```powershell
PS C:\> {{ Add example code here }}
```

{{ Add example description here }}

## PARAMETERS

## INPUTS

## OUTPUTS

### [hashtable] - A hashtable where keys are role names and values are arrays of scope strings.
## NOTES

## RELATED LINKS
