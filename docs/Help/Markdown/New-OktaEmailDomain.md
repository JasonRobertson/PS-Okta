---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# New-OktaEmailDomain

## SYNOPSIS
Creates a new custom email domain in Okta.

## SYNTAX

```
New-OktaEmailDomain [-Domain] <String> [-DisplayName] <String> [-BrandId] <String> [-Username] <String>
 [[-ValidationSubdomain] <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
This function allows you to configure a new custom email domain within your
Okta organization.
It requires details such as the domain name, a display
name, the associated Okta brand ID, a username for validation, and an
optional validation subdomain.
The function performs a lookup for the
Brand ID to ensure its validity before attempting to create the email
domain.

## EXAMPLES

### EXAMPLE 1
```
# Create a new email domain for 'example.com' associated with a brand
# named 'MyCompany_Default'
New-OktaEmailDomain -Domain "example.com" -DisplayName "Example Company Emails" -BrandId "MyCompany_Default" -Username "admin@example.com"
```

### EXAMPLE 2
```
# Create a new email domain with a custom validation subdomain
New-OktaEmailDomain -Domain "test.org" -DisplayName "Test Org Emails" -BrandId "0oa123abc456def7890" -Username "support@test.org" -ValidationSubdomain "oktavalidate"
```

## PARAMETERS

### -Domain
(Mandatory) Specifies the actual domain name you wish to add, e.g.,
\`example.com\`.
This will be the domain used for sending emails from Okta.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
(Mandatory) A user-friendly name for the email domain that will be
displayed in the Okta Admin Console.

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

### -BrandId
(Mandatory) The ID or name of the Okta brand to which this email domain
will be associated.
This function will internally resolve the actual
Brand ID using \`Get-OktaBrand\`.

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

### -Username
(Mandatory) The username associated with the email domain for validation
purposes.
This is typically an email address within the domain.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ValidationSubdomain
(Optional) The subdomain used for email domain validation.
The default
value is 'mail'.
This is typically used for DNS CNAME records required
by Okta for domain verification.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: Mail
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
This function relies on external Invoke-OktaAPI and Get-OktaBrand
functions for API calls and brand lookup, respectively.
It also uses
Write-OktaError for standardized error reporting.
Ensure these functions
are available in your PowerShell session.

## RELATED LINKS
