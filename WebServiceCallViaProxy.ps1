#Service URL
$url = "http://servername/_vti_bin/SiteData.asmx"
Write-Host "URL: $url" -ForegroundColor Green

#credentials, input user name if needed
$domain = Read-Host -Prompt "Please enter domain"
$user = Read-Host -Prompt "Please enter username"
$fqusername = "$domain\$user"
$pwdstring = Read-Host -Prompt "Please enter password for $fqusername" -AsSecureString
if($null -eq $pwdstring)
{
    Write-Error "Invalid password entered"
    return
}

$creds = New-Object System.Management.Automation.PSCredential($fqusername, $pwdstring)
$listproxy = New-WebServiceProxy -Uri $url -Credential $creds

$metadata = $null
$webs = $null
$users = $null
$groups = $null
$vGroups = $null
$listproxy.GetSite([ref]$metadata, [ref]$Webs, [ref]$users, [ref]$groups, [ref]$vGroups)

Write-Host "MetaData:" -NoNewline
$metadata

Write-Host "Webs:"
$webs

Write-Host "Users:"
$users

Write-Host "Groups:"
$groups

Write-Host "vGroups:"
$vGroups

$lists = $null
$listproxy.GetListCollection([ref]$lists)
$lists | Format-Table