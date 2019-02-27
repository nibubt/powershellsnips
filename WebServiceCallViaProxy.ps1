#Service URL
$url = "http://nt-sp2013-26/_vti_bin/SiteData.asmx"
$domain = "kesar"
$user = "administrator"
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