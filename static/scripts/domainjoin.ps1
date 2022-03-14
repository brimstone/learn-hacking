# Detect if anything actually needs to be done here
if ((gwmi win32_computersystem).partofdomain -eq $true) {
	exit
}

Write-Host 'Enable Ping'
$fw = New-Object -ComObject HNetCfg.FWPolicy2
#$fw.Rules | Format-Table Name, Enabled, Direction -AutoSize

$fw.Rules | where {$_.Name -like "File and Printer Sharing (Echo Request - ICMPv4-In)"} |
foreach {$_.Enabled = $true}

$fw.Rules | where {$_.Name -like "File and Printer Sharing (Echo Request - ICMPv4-In)"} |
Format-Table Name, Direction, Protocol, Profiles, Enabled -AutoSize

Write-Host 'Join the domain'

Start-Sleep -m 2000

Write-Host "First, set DNS to DC to join the domain"
$newDNSServers = "192.168.56.2"
Do {
	$Failed = $false
	$adapters = Get-WmiObject Win32_NetworkAdapterConfiguration | Where-Object {$_.IPAddress -match "192.168.56."}
	if (([array]$adapters).Count -lt 1 ) {
		Start-Sleep -m 2000
		$Failed = true
	}
} While ($Failed)
# TODO keep checking until there's an adapter that matches
Write-Host $adapters
$adapters | ForEach-Object {$_.SetDNSServerSearchOrder($newDNSServers)}

# TODO error when ping fails
ping dc1.stark.local

Write-Host "Now join the domain"

$user = "stark\vagrant"
$pass = ConvertTo-SecureString "vagrant" -AsPlainText -Force
$DomainCred = New-Object System.Management.Automation.PSCredential $user, $pass

# TODO possible to remove first, just incase of a complete box rebuild?
Remove-Computer -UnjoinDomainCredential $DomainCred -PassThru -Verbose -ErrorAction SilentlyContinue
Do {
	$Failed = $false
	Try {
		Add-Computer -DomainName "stark.local" -credential $DomainCred -PassThru -Verbose -ErrorAction Stop
	} Catch {
		$Failed = $true
	}
} While ($Failed)

Write-Host "Done, rebooting"
Start-Sleep -m 2000
shutdown /r /t 0
