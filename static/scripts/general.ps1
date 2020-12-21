# https://serverfault.com/questions/873522/how-do-i-completely-turn-off-windows-defender-from-powershell
# https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps

# Disable Automatic Sample Submission
if ([Environment]::OSVersion.Version -ge (new-object 'Version' 10,0,17763)) {
	# 2019 Server
	Set-MpPreference -SubmitSamplesConsent NeverSend
} else {
	# 2016 Server
	Set-MpPreference -SubmitSamplesConsent Never
}
# Disable Cloud-Based Protection
Set-MpPreference -MAPSReporting Disable

# Enable Guest access to SMB shares
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Type DWord -Value 1

# Disable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Download some tools
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/Procmon64.exe', 'c:\users\all users\desktop\ProcMon64.exe')
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/procexp64.exe', 'c:\users\all users\desktop\procexp64.exe')
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/Autoruns64.exe', 'c:\users\all users\desktop\Autoruns64.exe')

Set-SmbServerConfiguration -RequireSecuritySignature $false -Force
Set-SmbServerConfiguration -EnableSecuritySignature $false -Force
