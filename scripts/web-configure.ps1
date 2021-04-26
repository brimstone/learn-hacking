# TODO get list of users in group to determine if the user needs to be added
if (@((Get-WmiObject -Class Win32_Group -Filter 'Name="Administrators"').GetRelated() | Where { $_.Name -match "HTTP Admins"}).Count > 0) {
	exit
}
Write-Host "Adding HTTP Admins to local admins"

# Add HTTP Admins to local admins
$group = [ADSI]("WinNT://$env:COMPUTERNAME/administrators,group")
$group.add("WinNT://stark.local/http admins,group")

# Setup IIS
dism /online /enable-feature /featurename:IIS-Webserverrole
# Search with: Get-WindowsFeatures | findstr ""
Install-WindowsFeature -Name Web-Asp-Net45
Install-WindowsFeature -Name Web-Windows-Auth
Install-WindowsFeature -Name Web-Basic-Auth
netsh advfirewall set  currentprofile state off

# Allow authentication types to be changed with a web.config locally
c:\windows\system32\inetsrv\appcmd unlock config -section:anonymousAuthentication
c:\windows\system32\inetsrv\appcmd unlock config -section:windowsAuthentication
c:\windows\system32\inetsrv\appcmd unlock config -section:basicAuthentication

#shutdown /r /t 0
