# Adds >5000 users to AD, please use this script only for testing purposes.
Install-Module ActiveDirectory
$ad = Import-Module ActiveDirectory -PassThru
if($null -eq $ad)
{
    Write-Error "Failed to import AD Module, exiting script!"
    return
}

$userscsv = Import-Csv -Path C:\UserNames.csv -UseCulture
$Secure_String_Pwd = ConvertTo-SecureString "Access1" -AsPlainText -Force
$NeverExpires = [System.DateTime]::MaxValue

$groups = @("Group1","Group2","Group3")
$groups | ForEach-Object {
   New-ADGroup -Name $_ -SamAccountName $_ -Description "Nibu's Security group" -DisplayName $_ -GroupCategory Security -GroupScope DomainLocal -PassThru
}

$userscsv | ForEach-Object{
    $user = New-ADUser -Name $_.SamAccountName -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.SurName -Path "CN=Users,DC=kesar,DC=lab" -DisplayName $_.DisplayName -Department $_.Department -EmailAddress $_.Email -AccountPassword $Secure_String_Pwd -PasswordNeverExpires $true -AccountExpirationDate $NeverExpires -Enabled $true -Description "~~~Created from CSV File" -ErrorAction Ignore -PassThru -State "TX"
    if($user)
    {
        Write-Host "Adding user '$($user.SamAccountName)' to AD groups: '$groups'"
        $groups | ForEach-Object {
            $grp = Get-ADGroup $_
            Add-ADGroupMember $grp -Members $user.DistinguishedName
        }
    }
}
