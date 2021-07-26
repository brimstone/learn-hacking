$key = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
if ((Get-ItemProperty -Path "$key" -Name DefaultUserName -ErrorAction Ignore).DefaultUserName -ne "stark\tony") {
	Set-ItemProperty "$key" -Name AutoAdminLogon -Value 1
	Set-ItemProperty "$key" -Name DefaultUserName -Value "stark\tony"
	Set-ItemProperty "$key" -Name DefaultPassword -Value "tony"
	Write-Host "Done, rebooting"
	Start-Sleep -m 2000
	shutdown /r /t 0
}

#Set-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon" -Name DefaultDomainName -Value "parentdomain"
