---
external help file: PS-Okta-help.xml
Module Name: PS-Okta
online version:
schema: 2.0.0
---

# New-DynamicParameter

## SYNOPSIS
Helper function to simplify creating dynamic parameters

## SYNTAX

### DynamicParameter (Default)
```
New-DynamicParameter -Name <String> [-Type <Type>] [-Alias <String[]>] [-Mandatory] [-Position <Int32>]
 [-HelpMessage <String>] [-DontShow] [-ValueFromPipeline] [-ValueFromPipelineByPropertyName]
 [-ValueFromRemainingArguments] [-ParameterSetName <String>] [-AllowNull] [-AllowEmptyString]
 [-AllowEmptyCollection] [-ValidateNotNull] [-ValidateNotNullOrEmpty] [-ValidateCount <Int32[]>]
 [-ValidateRange <Int32[]>] [-ValidateLength <Int32[]>] [-ValidatePattern <String>]
 [-ValidateScript <ScriptBlock>] [-ValidateSet <String[]>] [-Dictionary <Object>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

### CreateVariables
```
New-DynamicParameter [-CreateVariables] -BoundParameters <Object> [-ProgressAction <ActionPreference>]
 [<CommonParameters>]
```

## DESCRIPTION
Helper function to simplify creating dynamic parameters.

Example use cases:
	Include parameters only if your environment dictates it
	Include parameters depending on the value of a user-specified parameter
	Provide tab completion and intellisense for parameters, depending on the environment

Please keep in mind that all dynamic parameters you create, will not have corresponding variables created.
	Use New-DynamicParameter with 'CreateVariables' switch in your main code block,
	('Process' for advanced functions) to create those variables.
	Alternatively, manually reference $PSBoundParameters for the dynamic parameter value.

This function has two operating modes:

1.
All dynamic parameters created in one pass using pipeline input to the function.
This mode allows to create dynamic parameters en masse,
with one function call.
There is no need to create and maintain custom RuntimeDefinedParameterDictionary.

2.
Dynamic parameters are created by separate function calls and added to the RuntimeDefinedParameterDictionary you created beforehand.
Then you output this RuntimeDefinedParameterDictionary to the pipeline.
This allows more fine-grained control of the dynamic parameters,
with custom conditions and so on.

## EXAMPLES

### EXAMPLE 1
```
Create one dynamic parameter.
```

This example illustrates the use of New-DynamicParameter to create a single dynamic parameter.
The Drive's parameter ValidateSet is populated with all available volumes on the computer for handy tab completion / intellisense.

Usage: Get-FreeSpace -Drive \<tab\>

function Get-FreeSpace
{
	\[CmdletBinding()\]
	Param()
	DynamicParam
	{
		# Get drive names for ValidateSet attribute
		$DriveList = (\[System.IO.DriveInfo\]::GetDrives()).Name

		# Create new dynamic parameter
		New-DynamicParameter -Name Drive -ValidateSet $DriveList -Type (\[array\]) -Position 0 -Mandatory
	}

	Process
	{
		# Dynamic parameters don't have corresponding variables created,
		# you need to call New-DynamicParameter with CreateVariables switch to fix that.
		New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

		$DriveInfo = \[System.IO.DriveInfo\]::GetDrives() | Where-Object {$Drive -contains $_.Name}
		$DriveInfo |
			ForEach-Object {
				if(!$_.TotalFreeSpace)
				{
					$FreePct = 0
				}
				else
				{
					$FreePct = \[System.Math\]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
				}
				New-Object -TypeName psobject -Property @{
					Drive = $_.Name
					DriveType = $_.DriveType
					'Free(%)' = $FreePct
				}
			}
	}
}

### EXAMPLE 2
```
Create several dynamic parameters not using custom RuntimeDefinedParameterDictionary (requires piping).
```

In this example two dynamic parameters are created.
Each parameter belongs to the different parameter set, so they are mutually exclusive.

The Drive's parameter ValidateSet is populated with all available volumes on the computer.
The DriveType's parameter ValidateSet is populated with all available drive types.

Usage: Get-FreeSpace -Drive \<tab\>
	or
Usage: Get-FreeSpace -DriveType \<tab\>

Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

function Get-FreeSpace
{
	\[CmdletBinding()\]
	Param()
	DynamicParam
	{
		# Array of hashtables that hold values for dynamic parameters
		$DynamicParameters = @(
			@{
				Name = 'Drive'
				Type = \[array\]
				Position = 0
				Mandatory = $true
				ValidateSet = (\[System.IO.DriveInfo\]::GetDrives()).Name
				ParameterSetName = 'Drive'
			},
			@{
				Name = 'DriveType'
				Type = \[array\]
				Position = 0
				Mandatory = $true
				ValidateSet = \[System.Enum\]::GetNames('System.IO.DriveType')
				ParameterSetName = 'DriveType'
			}
		)

		# Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
		# to create all dynamic parameters in one function call.
		$DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
	}
	Process
	{
		# Dynamic parameters don't have corresponding variables created,
		# you need to call New-DynamicParameter with CreateVariables switch to fix that.
		New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

		if($Drive)
		{
			$Filter = {$Drive -contains $_.Name}
		}
		elseif($DriveType)
		{
			$Filter =  {$DriveType -contains  $_.DriveType}
		}

		$DriveInfo = \[System.IO.DriveInfo\]::GetDrives() | Where-Object $Filter
		$DriveInfo |
			ForEach-Object {
				if(!$_.TotalFreeSpace)
				{
					$FreePct = 0
				}
				else
				{
					$FreePct = \[System.Math\]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
				}
				New-Object -TypeName psobject -Property @{
					Drive = $_.Name
					DriveType = $_.DriveType
					'Free(%)' = $FreePct
				}
			}
	}
}

### EXAMPLE 3
```
Create several dynamic parameters, with multiple Parameter Sets, not using custom RuntimeDefinedParameterDictionary (requires piping).
```

In this example three dynamic parameters are created.
Two of the parameters are belong to the different parameter set, so they are mutually exclusive.
One of the parameters belongs to both parameter sets.

The Drive's parameter ValidateSet is populated with all available volumes on the computer.
The DriveType's parameter ValidateSet is populated with all available drive types.
The DriveType's parameter ValidateSet is populated with all available drive types.
The Precision's parameter controls number of digits after decimal separator for Free Space percentage.

Usage: Get-FreeSpace -Drive \<tab\> -Precision 2
	or
Usage: Get-FreeSpace -DriveType \<tab\> -Precision 2

Parameters are defined in the array of hashtables, which is then piped through the New-Object to create PSObject and pass it to the New-DynamicParameter function.
If parameter with the same name already exist in the RuntimeDefinedParameterDictionary, a new Parameter Set is added to it.
Because of piping, New-DynamicParameter function is able to create all parameters at once, thus eliminating need for you to create and pass external RuntimeDefinedParameterDictionary to it.

function Get-FreeSpace
{
	\[CmdletBinding()\]
	Param()
	DynamicParam
	{
		# Array of hashtables that hold values for dynamic parameters
		$DynamicParameters = @(
			@{
				Name = 'Drive'
				Type = \[array\]
				Position = 0
				Mandatory = $true
				ValidateSet = (\[System.IO.DriveInfo\]::GetDrives()).Name
				ParameterSetName = 'Drive'
			},
			@{
				Name = 'DriveType'
				Type = \[array\]
				Position = 0
				Mandatory = $true
				ValidateSet = \[System.Enum\]::GetNames('System.IO.DriveType')
				ParameterSetName = 'DriveType'
			},
			@{
				Name = 'Precision'
				Type = \[int\]
				# This will add a Drive parameter set to the parameter
				Position = 1
				ParameterSetName = 'Drive'
			},
			@{
				Name = 'Precision'
				# Because the parameter already exits in the RuntimeDefinedParameterDictionary,
				# this will add a DriveType parameter set to the parameter.
				Position = 1
				ParameterSetName = 'DriveType'
			}
		)

		# Convert hashtables to PSObjects and pipe them to the New-DynamicParameter,
		# to create all dynamic parameters in one function call.
		$DynamicParameters | ForEach-Object {New-Object PSObject -Property $_} | New-DynamicParameter
	}
	Process
	{
		# Dynamic parameters don't have corresponding variables created,
		# you need to call New-DynamicParameter with CreateVariables switch to fix that.
		New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

		if($Drive)
		{
			$Filter = {$Drive -contains $_.Name}
		}
		elseif($DriveType)
		{
			$Filter = {$DriveType -contains  $_.DriveType}
		}

		if(!$Precision)
		{
			$Precision = 2
		}

		$DriveInfo = \[System.IO.DriveInfo\]::GetDrives() | Where-Object $Filter
		$DriveInfo |
			ForEach-Object {
				if(!$_.TotalFreeSpace)
				{
					$FreePct = 0
				}
				else
				{
					$FreePct = \[System.Math\]::Round(($_.TotalSize / $_.TotalFreeSpace), $Precision)
				}
				New-Object -TypeName psobject -Property @{
					Drive = $_.Name
					DriveType = $_.DriveType
					'Free(%)' = $FreePct
				}
			}
	}
}

### EXAMPLE 4
```
Create dynamic parameters using custom dictionary.
```

In case you need more control, use custom dictionary to precisely choose what dynamic parameters to create and when.
The example below will create DriveType dynamic parameter only if today is not a Friday:

function Get-FreeSpace
{
	\[CmdletBinding()\]
	Param()
	DynamicParam
	{
		$Drive = @{
			Name = 'Drive'
			Type = \[array\]
			Position = 0
			Mandatory = $true
			ValidateSet = (\[System.IO.DriveInfo\]::GetDrives()).Name
			ParameterSetName = 'Drive'
		}

		$DriveType =  @{
			Name = 'DriveType'
			Type = \[array\]
			Position = 0
			Mandatory = $true
			ValidateSet = \[System.Enum\]::GetNames('System.IO.DriveType')
			ParameterSetName = 'DriveType'
		}

		# Create dictionary
		$DynamicParameters = New-Object System.Management.Automation.RuntimeDefinedParameterDictionary

		# Add new dynamic parameter to dictionary
		New-DynamicParameter @Drive -Dictionary $DynamicParameters

		# Add another dynamic parameter to dictionary, only if today is not a Friday
		if((Get-Date).DayOfWeek -ne \[DayOfWeek\]::Friday)
		{
			New-DynamicParameter @DriveType -Dictionary $DynamicParameters
		}

		# Return dictionary with dynamic parameters
		$DynamicParameters
	}
	Process
	{
		# Dynamic parameters don't have corresponding variables created,
		# you need to call New-DynamicParameter with CreateVariables switch to fix that.
		New-DynamicParameter -CreateVariables -BoundParameters $PSBoundParameters

		if($Drive)
		{
			$Filter = {$Drive -contains $_.Name}
		}
		elseif($DriveType)
		{
			$Filter =  {$DriveType -contains  $_.DriveType}
		}

		$DriveInfo = \[System.IO.DriveInfo\]::GetDrives() | Where-Object $Filter
		$DriveInfo |
			ForEach-Object {
				if(!$_.TotalFreeSpace)
				{
					$FreePct = 0
				}
				else
				{
					$FreePct = \[System.Math\]::Round(($_.TotalSize / $_.TotalFreeSpace), 2)
				}
				New-Object -TypeName psobject -Property @{
					Drive = $_.Name
					DriveType = $_.DriveType
					'Free(%)' = $FreePct
				}
			}
	}
}

## PARAMETERS

### -Name
Name of the dynamic parameter

```yaml
Type: String
Parameter Sets: DynamicParameter
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Type
Type for the dynamic parameter. 
Default is string

```yaml
Type: Type
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: Int
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Alias
If specified, one or more aliases to assign to the dynamic parameter

```yaml
Type: String[]
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Mandatory
If specified, set the Mandatory attribute for this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Position
If specified, set the Position attribute for this dynamic parameter

```yaml
Type: Int32
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: 0
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -HelpMessage
If specified, set the HelpMessage for this dynamic parameter

```yaml
Type: String
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -DontShow
If specified, set the DontShow for this dynamic parameter.
This is the new PowerShell 4.0 attribute that hides parameter from tab-completion.
http://www.powershellmagazine.com/2013/07/29/pstip-hiding-parameters-from-tab-completion/

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValueFromPipeline
If specified, set the ValueFromPipeline attribute for this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValueFromPipelineByPropertyName
If specified, set the ValueFromPipelineByPropertyName attribute for this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValueFromRemainingArguments
If specified, set the ValueFromRemainingArguments attribute for this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ParameterSetName
If specified, set the ParameterSet attribute for this dynamic parameter.
By default parameter is added to all parameters sets.

```yaml
Type: String
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: __AllParameterSets
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AllowNull
If specified, set the AllowNull attribute of this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AllowEmptyString
If specified, set the AllowEmptyString attribute of this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -AllowEmptyCollection
If specified, set the AllowEmptyCollection attribute of this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateNotNull
If specified, set the ValidateNotNull attribute of this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateNotNullOrEmpty
If specified, set the ValidateNotNullOrEmpty attribute of this dynamic parameter

```yaml
Type: SwitchParameter
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateCount
{{ Fill ValidateCount Description }}

```yaml
Type: Int32[]
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateRange
If specified, set the ValidateRange attribute of this dynamic parameter

```yaml
Type: Int32[]
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateLength
If specified, set the ValidateLength attribute of this dynamic parameter

```yaml
Type: Int32[]
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidatePattern
If specified, set the ValidatePattern attribute of this dynamic parameter

```yaml
Type: String
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateScript
If specified, set the ValidateScript attribute of this dynamic parameter

```yaml
Type: ScriptBlock
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -ValidateSet
If specified, set the ValidateSet attribute of this dynamic parameter

```yaml
Type: String[]
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -Dictionary
If specified, add resulting RuntimeDefinedParameter to an existing RuntimeDefinedParameterDictionary.
Appropriate for custom dynamic parameters creation.

If not specified, create and return a RuntimeDefinedParameterDictionary
Aappropriate for a simple dynamic parameter creation.

```yaml
Type: Object
Parameter Sets: DynamicParameter
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -CreateVariables
{{ Fill CreateVariables Description }}

```yaml
Type: SwitchParameter
Parameter Sets: CreateVariables
Aliases:

Required: True
Position: Named
Default value: False
Accept pipeline input: True (ByPropertyName)
Accept wildcard characters: False
```

### -BoundParameters
System.Management.Automation.PSBoundParametersDictionary is an internal sealed class,
so one can't use PowerShell's '-is' operator to validate type.

```yaml
Type: Object
Parameter Sets: CreateVariables
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: True (ByPropertyName)
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
Credits to jrich523 and ramblingcookiemonster for their initial code and inspiration:
	https://github.com/RamblingCookieMonster/PowerShell/blob/master/New-DynamicParam.ps1
	http://ramblingcookiemonster.wordpress.com/2014/11/27/quick-hits-credentials-and-dynamic-parameters/
	http://jrich523.wordpress.com/2013/05/30/powershell-simple-way-to-add-dynamic-parameters-to-advanced-function/

Credit to BM for alias and type parameters and their handling

## RELATED LINKS
