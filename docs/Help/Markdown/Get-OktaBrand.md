---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Get-OktaBrand

## SYNOPSIS
Retrieves detailed Okta brand configurations and properties.

## SYNTAX

```
Get-OktaBrand [[-Identity] <String>] [[-Limit] <Int32>] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
This function interacts with the Okta API to fetch information about Okta
brands.
It can retrieve a specific brand by its unique **ID** or through
a partial or full **name match**.
Alternatively, you can list multiple
brands by specifying a **limit** on the number of results.
The function
handles API communication and error reporting, returning a refined dataset
focused on the \`defaultApp\` properties of the retrieved brands, while
excluding extraneous metadata for a cleaner output.

## EXAMPLES

### EXAMPLE 1
```
# Retrieve a specific Okta brand by its unique ID
Get-OktaBrand -Identity "0oa786gznlVSf15sC5d7"
```

### EXAMPLE 2
```
# Search for Okta brands with names containing "dev"
Get-OktaBrand -Identity "dev"
```

### EXAMPLE 3
```
# Get the first 20 Okta brands when no specific identity is provided
Get-OktaBrand -Limit 20
```

## PARAMETERS

### -Identity
Specifies the **ID** (e.g., \`0oa786gznlVSf15sC5d7\`) or **name** (e.g.,
\`dev-56213942_default\`) of the Okta brand to retrieve.
If an ID is
provided, it attempts an exact match.
If a name is provided, it performs a
case-insensitive wildcard search.
If this parameter is omitted, the
function retrieves a list of all brands up to the specified \`Limit\`.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Limit
Defines the **maximum number of Okta brands** to return when no \`Identity\`
is specified or when multiple brands match a partial name search.
The
acceptable range for this value is **1 to 1000**.
The default value is
**200**, which provides a reasonable number of results without causing
excessively large API responses.

```yaml
Type: Int32
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: 200
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

## NOTES
This function relies on external \`Invoke-OktaAPI\` and \`Write-OktaError\`
functions for API calls and standardized error reporting, respectively.
Ensure these functions are available in your PowerShell session.
The
\`defaultApp\` property is expanded, and both the \`_links\` and \`defaultApp\`
properties themselves are excluded from the final output for clarity.

## RELATED LINKS
