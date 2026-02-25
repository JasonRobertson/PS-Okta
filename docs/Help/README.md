# Updatable Help for PS-Okta

This folder contains **HelpInfo XML** and **MAML** help used for PowerShell's `Update-Help` and for the module's Get-Help content.

## Contents

- **PS-Okta_*_HelpInfo.xml** – HelpInfo file for Update-Help (lists UI cultures and help content version).
- **en-US/** – MAML help files (e.g. `PS-Okta.psm1-help.xml`) for the en-US locale.

## Regenerating help (platyPS)

After building the module (`Scripts\Start-ModuleBuild.ps1`), you can regenerate Markdown, MAML, and HelpInfo using platyPS:

```powershell
Install-Module platyPS -Scope CurrentUser
.\Scripts\Export-ModuleHelp.ps1
```

Output is written here (`docs\Help`). To enable `Update-Help`, host these files at a URL and set **HelpInfoURI** in the module manifest to that location.
