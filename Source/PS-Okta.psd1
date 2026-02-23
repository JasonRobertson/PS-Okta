@{
RootModule = "PS-Okta.psm1"
ModuleVersion = "1.0.3"
GUID = "463b75af-afc8-480a-98f4-fb1bddcfff24"
Author = "Jason Robertson"
CompanyName = "Jason Robertson"
Copyright = "Copyright ©2022 Jason Robertson"
Description = "Is an unofficial module built for Okta Administrators who like to use PowerShell to complete administrative tasks quickly and efficiently. The module does not use any of Okta's official SDKs, but instead uses the Invoke-RestMethod and Invoke-WebRequest functions to interact with Okta's APIs directly."
PowerShellVersion = "7.0"
FunctionsToExport = "*"
CmdletsToExport = @()
VariablesToExport = ""
AliasesToExport = @()
PrivateData = @{
    PSData = @{
        Tags = @("PSModule", "Okta", "API")
        LicenseUri = "https://github.com/YourOrg/PS-Okta/blob/main/LICENSE"
        ProjectUri = "https://github.com/JasonRobertson/PS-Okta"
        ReleaseNotes = "Get-OktaUser: extended filters (FirstName, LastName, Manager, Country, CountryCode, City, WorkerType, Domain, Department, Division, Organization, CostCenter, EmployeeNumber, UserType); dynamic Type parameter (Okta user type via type.id) with display-name completion. Build: module index (Export-ModuleIndex), Scripts layout, LICENSE in output."
    }
}
HelpInfoURI = "https://raw.githubusercontent.com/JasonRobertson/PS-Okta/main/docs/Help/PS-Okta_1.0.3.0_HelpInfo.xml"
}
