#credentials, change user name if needed
$domain = "kesar"
$user = "Administrator"
$fqusername = "$domain\$user"
$pwdstring = Read-Host -Prompt "Please enter password for $fqusername" -AsSecureString
if($null -eq $pwdstring)
{
    Write-Error "Invalid password entered"
    return
}
$creds = New-Object System.Management.Automation.PSCredential($fqusername, $pwdstring)

# Prepare SOAP message
$url = "http://server/_vti_bin/sitedata.asmx"

$soapbody = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://www.w3.org/2003/05/soap-envelope">
  <soap:Body>
    <GetSite xmlns="http://schemas.microsoft.com/sharepoint/soap/" />
  </soap:Body>
</soap:Envelope>
"@

#Prepare SOAP Header...
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("User-Agent", "Mozilla/4.0")
$headers.Add("Content-Type", 'application/soap+xml;charset=UTF-8')
$headers.Add("Content-Length", $soapbody.Length);

#Send the request
$lists = Invoke-WebRequest -Method Post -Uri $url -Headers $headers -Body $soapbody -SessionVariable sessionvar -Credential $creds

#Dump output
$xml = [xml]$lists.Content
$xml.Envelope.Body.GetListCollectionResponse.GetListCollectionResult.Lists | ForEach-Object{$_.List} | Select-Object Title, ID | Format-Table -AutoSize