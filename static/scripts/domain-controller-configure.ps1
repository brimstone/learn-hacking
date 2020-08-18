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
$howardPassword = ConvertTo-SecureString -AsPlainText 'Howard19' + (10..99 | Get-Random) -Force
$tonyPassword = ConvertTo-SecureString -AsPlainText 'tony' -Force
$mariaPassword = ConvertTo-SecureString -AsPlainText 'Tony@1970' -Force
$SvcAcctPwd = ConvertTo-SecureString -AsPlainText 'P@ssw0rd1' -Force
$AdminstratorPassword = ConvertTo-SecureString 'YouMortal!HowDareYouQuestionThe1?' -AsPlainText -Force

Set-ADDefaultDomainPasswordPolicy -Identity parent -ComplexityEnabled $false -MinPasswordLength 1
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


# add tester.
$name = 'hstark'
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
$name = 'MStark'
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

# add Rebecca Howe.
$name = 'tony'
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

# add Svc Acct.
$name = 'svc.acct'
New-ADUser `
    -Path $usersAdPath `
    -Name $name `
    -DisplayName 'Svc Acct' `
    -AccountPassword $SvcAcctPwd `
    -Enabled $true `
    -ServicePrincipalNames "MSSQLSVC/parentSQL.parentdomain.local" `
    -PasswordNeverExpires $true


New-ADComputer `
   -Description "Who is a good computer? I'm a good computer." `
   -DisplayName "parentWkstn" `
   -DNSHostName "parentWkstn.ParentDomain.local" `
   -Enabled $True `
   -Name "parentWkstn" `
   -SAMAccountName "parentWkstn"

New-ADComputer `
   -Description "Who is a good computer? I'm a good computer." `
   -DisplayName "parentSQL" `
   -DNSHostName "parentSQL.parentdomain.local" `
   -Enabled $True `
   -Name "parentSQL" `
   -SAMAccountName "parentSQL"

Get-ADComputer -Identity 'parentWkstn' | Set-ADAccountControl -TrustedToAuthForDelegation $true
Set-ADComputer -Identity 'parentWkstn' -Add @{'msDS-AllowedToDelegateTo'=@('cifs/PARENTDC')}

echo 'Howard Stark Group Membership'
Get-ADPrincipalGroupMembership -Identity 'hstark' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Maria Stark Group Membership'
Get-ADPrincipalGroupMembership -Identity 'mstark' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'svc.acct Group Membership'
Get-ADPrincipalGroupMembership -Identity 'svc.acct' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'vagrant Group Membership'
Get-ADPrincipalGroupMembership -Identity 'vagrant' `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

echo 'Tony StarkGroup Membership'
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


echo 'Enabled Domain User Accounts'
Get-ADUser -Filter {Enabled -eq $true} `
    | Select-Object Name,DistinguishedName,SID `
    | Format-Table -AutoSize | Out-String -Width 2000

