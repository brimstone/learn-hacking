# wait until we can access the AD. this is needed to prevent errors like:
#   Unable to find a default server with Active Directory Web Services running.
while ($true) {
    try {
        Get-ADDomain | Out-Null
        break
    } catch {
        Start-Sleep -Seconds 10
    }
}


$adDomain = Get-ADDomain
$domain = $adDomain.DNSRoot
$domainDn = $adDomain.DistinguishedName
$usersAdPath = "CN=Users,$domainDn"
$howardPassword = ConvertTo-SecureString -AsPlainText ('Howard19' + (10..99 | Get-Random)) -Force
$tonyPassword = ConvertTo-SecureString -AsPlainText 'tony' -Force
$mariaPassword = ConvertTo-SecureString -AsPlainText 'Tony@1970' -Force
$jarvisHTTPPassword = ConvertTo-SecureString -AsPlainText 'P@ssw0rd1' -Force
$AdminstratorPassword = ConvertTo-SecureString 'YouMortal!HowDareYouQuestionThe1?' -AsPlainText -Force

New-ADGroup -Name "HTTP Admins" `
    -SamAccountName "HTTP Admins" `
    -GroupCategory Security `
    -GroupScope Global `
    -DisplayName "HTTP Administrators" `
    -Path "$usersAdPath" `
    -Description "Members of this group are Administrators of HTTP servers"

Set-ADDefaultDomainPasswordPolicy -Identity stark -ComplexityEnabled $false -MinPasswordLength 1
# add the vagrant user to the Enterprise Admins group.
# NB this is needed to install the Enterprise Root Certification Authority.
Add-ADGroupMember `
    -Identity 'Enterprise Admins' `
    -Members "CN=vagrant,$usersAdPath"

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=vagrant,$usersAdPath"

# set the Administrator password.
# NB this is also an Domain Administrator account.
Set-ADAccountPassword `
    -Identity "CN=Administrator,$usersAdPath" `
    -Reset `
    -NewPassword $AdminstratorPassword
Set-ADUser `
    -Identity "CN=Administrator,$usersAdPath" `
    -PasswordNeverExpires $true


# add Howard
$name = 'Howard'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -DisplayName 'Howard Stark' `
    -AccountPassword $howardPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Maria
$name = 'Maria'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Maria' `
    -Surname 'Stark' `
    -DisplayName 'Maria Stark' `
    -AccountPassword $mariaPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

Add-ADGroupMember `
    -Identity 'Domain Admins' `
    -Members "CN=$name,$usersAdPath"

# add Tony
$name = 'Tony'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -UserPrincipalName "$name@$domain" `
    -EmailAddress "$name@$domain" `
    -GivenName 'Tony' `
    -Surname 'Stark' `
    -DisplayName 'Tony Stark' `
    -AccountPassword $tonyPassword `
    -Enabled $true `
    -PasswordNeverExpires $true

# add Service Account for Jarvis
$name = 'Jarvis-HTTP'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -DisplayName 'HTTP Service Account for Jarvis' `
    -AccountPassword $jarvisHTTPPassword `
    -Enabled $true `
    -ServicePrincipalNames "HTTP/Jarvis-HTTP.stark.local" `
    -PasswordNeverExpires $true
Add-ADGroupMember `
    -Identity 'HTTP Admins' `
    -Members "CN=Jarvis-HTTP,$usersAdPath"

New-ADComputer `
   -Description "Who is a good computer? I'm a good computer." `
   -DisplayName "web1" `
   -DNSHostName "web1.stark.local" `
   -Enabled $True `
   -Name "WEB1" `
   -SAMAccountName "WEB1"
# Unconstrained Delegation
Get-ADComputer -Identity WEB1 | Set-ADAccountControl -TrustedForDelegation $true

# TODO is this useful?
#Get-ADComputer -Identity 'pc-tony' | Set-ADAccountControl -TrustedToAuthForDelegation $true
#Set-ADComputer -Identity 'pc-tony' -Add @{'msDS-AllowedToDelegateTo'=@('cifs/STARK')}

echo 'Howard Stark Group Membership'
Get-ADPrincipalGroupMembership -Identity 'howard' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Maria Stark Group Membership'
Get-ADPrincipalGroupMembership -Identity 'maria' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Jarvis-http Group Membership'
Get-ADPrincipalGroupMembership -Identity 'Jarvis-HTTP' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Tony Group Membership'
Get-ADPrincipalGroupMembership -Identity 'tony' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Enterprise Administrators'
Get-ADGroupMember `
    -Identity 'Enterprise Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Domain Administrators'
Get-ADGroupMember `
    -Identity 'Domain Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'HTTP Administrators'
Get-ADGroupMember `
    -Identity 'HTTP Admins' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000


echo 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

