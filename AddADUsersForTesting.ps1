# By Nibu Babu Thomas - Microsoft
# Adds >5000 users to AD, please use this script only for testing purposes.

Install-Module ActiveDirectory
$ad = Import-Module ActiveDirectory -PassThru
if($null -eq $ad)
{
    Write-Error "Failed to import AD Module, exiting script!"
    return
}

#Change these values if needed
$pwd = "SomePWD1"
$domains = "DC=kesar,DC=lab"

$userscsv = Import-Csv -Path ".\UserNames.csv" -UseCulture
$Secure_String_Pwd = ConvertTo-SecureString $pwd -AsPlainText -Force
$NeverExpires = [System.DateTime]::MaxValue

#Change group names if needed
$groups = @("Group1","Group2","Group3")
$groups | ForEach-Object {
   New-ADGroup -Name $_ -SamAccountName $_ -Description "Security group" -DisplayName $_ -GroupCategory Security -GroupScope DomainLocal -PassThru
}

$userscsv | ForEach-Object{
    $user = New-ADUser -Name $_.SamAccountName -SamAccountName $_.SamAccountName -GivenName $_.GivenName -Surname $_.SurName -Path "CN=Users,$domains" -DisplayName $_.DisplayName -Department $_.Department -EmailAddress $_.Email -AccountPassword $Secure_String_Pwd -PasswordNeverExpires $true -AccountExpirationDate $NeverExpires -Enabled $true -Description "~~~Created from CSV File" -ErrorAction Ignore -PassThru -State "TX"
    if($user)
    {
        Write-Host "Adding user '$($user.SamAccountName)' to AD groups: '$groups'"
        $groups | ForEach-Object {
            $grp = Get-ADGroup $_
            Add-ADGroupMember $grp -Members $user.DistinguishedName
        }
    }
}