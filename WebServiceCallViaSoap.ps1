#Credentials, change user name if needed
$domain = Read-Host -Prompt "Please enter domain"
$user =  Read-Host -Prompt "Please enter username"
$fqusername = "$domain\$user"
$pwdstring = Read-Host -Prompt "Please enter password for $fqusername" -AsSecureString
if($null -eq $pwdstring)
{
    Write-Error "Invalid password entered"
    return
}
$creds = New-Object System.Management.Automation.PSCredential($fqusername, $pwdstring)
  
#Prepare SOAP message
$url = "http://server/_vti_bin/sitedata.asmx"

$soapbody = @"
<?xml version="1.0" encoding="utf-8"?>
<soap12:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap12="http://www.w3.org/2003/05/soap-envelope">
  <soap12:Body>
    <GetListCollection xmlns="http://schemas.microsoft.com/sharepoint/soap/" />
  </soap12:Body>
</soap12:Envelope>
"@

#Prepare SOAP Header...
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("User-Agent", "Mozilla/4.0")
$headers.Add("Content-Type", 'application/soap+xml;charset=UTF-8')
$headers.Add("Content-Length", $soapbody.Length);

#Send the request
$lists = Invoke-WebRequest -Method "POST" -Uri $url -Headers $headers -Body $soapbody -Credential $creds

#Dump output
$xml = [xml]$lists.Content
$xml.Envelope.Body.GetListCollectionResponse.vLists | ForEach-Object{$_._sList} | Format-Table -AutoSize