# https://serverfault.com/questions/873522/how-do-i-completely-turn-off-windows-defender-from-powershell
# https://docs.microsoft.com/en-us/powershell/module/defender/set-mppreference?view=win10-ps

#Write-Host ([Environment]::OSVersion).Version
$key = "HKLM:\SOFTWARE\Policies\Microsoft\Windows Defender"

if ((Get-ItemProperty -Path "$key" -Name DisableAntiSpyware -ErrorAction Ignore).DisableAntiSpyware -eq 1)  {
	Write-Host "Windows Defender is disabled, enabling now"
	Remove-ItemProperty -Path "$key" -Name DisableAntiSpyware
	While ((Get-Service WinDefend).Status -ne "Running") {
		Write-Host "Waiting 30s for Defender to start"
		Start-Sleep -Seconds 30
	}
}

Write-Host "Disabling Sample Submission"
Set-MpPreference -SubmitSamplesConsent Never

Write-Host "Disabling Cloud Reporting"
Set-MpPreference -MAPSReporting Disable

# Enable Guest access to SMB shares
# TODO set $needsReboot
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanWorkstation\Parameters" -Name "AllowInsecureGuestAuth" -Type DWord -Value 1

# Disable Windows Firewall
Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False

# Download some tools
# TODO only download if missing
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/Procmon64.exe', 'c:\users\all users\desktop\ProcMon64.exe')
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/procexp64.exe', 'c:\users\all users\desktop\procexp64.exe')
(New-Object System.Net.WebClient).DownloadFile('http://live.sysinternals.com/Autoruns64.exe', 'c:\users\all users\desktop\Autoruns64.exe')

# TODO check, then set $needsReboot
Set-SmbServerConfiguration -RequireSecuritySignature $false -Force
Set-SmbServerConfiguration -EnableSecuritySignature $false -Force

if ($needsReboot -eq 1) {
	shutdown /r /t 0
}
