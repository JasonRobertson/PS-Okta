---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# Connect-Okta

## SYNOPSIS
Connect-Okta is used to establish the connection to the Organization Okta.

## SYNTAX

### ClientCredentials (Default)
```
Connect-Okta [-Domain <String>] [-ClientSecret <SecureString>] [-Scopes <String[]>] [-Preview]
 [-ClientID <String>] [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### ApiToken
```
Connect-Okta [-Domain <String>] [-ApiToken <PSCredential>] [-Preview] [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Connect-Okta is used to establish the connection to the Organization Okta.
Requires an API Token generated within Okta Admin Portal.

## EXAMPLES

### EXAMPLE 1
```
$secret = Read-Host -AsSecureString -Prompt 'Enter your Okta application client secret'
PS C:\> Connect-Okta -Domain my-org -ClientID '0oa123456789abcdefg' -ClientSecret $secret
```

Connected successfully to 'My Company' as 'My M2M App'

CompanyName : My Company
Domain      : my-org
URI         : https://my-org.okta.com/api/v1
User        : My M2M App
UserID      : 0oa123456789abcdefg

Connects to Okta using the recommended OAuth 2.0 Client Credentials flow.
This is the preferred method for automation and service accounts.

### EXAMPLE 2
```
# This will open a secure prompt. Enter any username and paste your Okta API Token into the password field.
PS C:\> $cred = Get-Credential -Message 'Enter your Okta API Token'
PS C:\> Connect-Okta -Domain my-org -ApiToken $cred
```

Connects to Okta using an API Token, securely prompting for the token.
This is the recommended method for interactive administrative tasks.

## PARAMETERS

### -Domain
{{ Fill Domain Description }}

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ApiToken
--- API Token Parameter Set ---

```yaml
Type: PSCredential
Parameter Sets: ApiToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientSecret
--- Client Credentials Parameter Set (ClientSecret is unique to this set) ---

```yaml
Type: SecureString
Parameter Sets: ClientCredentials
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Scopes
--- Scopes for Client Credentials ---

```yaml
Type: String[]
Parameter Sets: ClientCredentials
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Preview
--- Common Parameters ---

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -ClientID
--- Client Credentials Parameter ---

```yaml
Type: String
Parameter Sets: ClientCredentials
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

### A connection object is stored in the session. Status information is written to the host.
## NOTES
No other cmdlets will work without having run Connect-Okta first.

## RELATED LINKS
