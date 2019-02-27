#credentials, change user name if needed
$domain = "kesar"
$user = "Administrator"
$fqusername = "$domain\$user"
$pwdstring = Read-Host -Prompt "Please enter password for $fqusername : " -AsSecureString
if($pwdstring -eq $null)
{
    Write-Error "Invalid password entered"
    return
}
$creds = New-Object System.Management.Automation.PSCredential($fqusername, $pwdstring)

# Prepare SOAP message
$url = "http://nt-sp2013-26/_vti_bin/lists.asmx"
$ct = "text/xml"
$soapbody = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
    <soap:Body><GetListCollection xmlns="http://schemas.microsoft.com/sharepoint/soap/" />
    </soap:Body>
</soap:Envelope>
"@

#Prepare SOAP Header...
$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("User-Agent", "Mozilla/4.0")
$headers.Add("Content-Type", 'text/xml;charset=UTF-8')
$headers.Add("SOAPAction", "http://schemas.microsoft.com/sharepoint/soap/GetListCollection")
$headers.Add("Content-Length", $soapbody.Length);
$headers.Add("Transfer-Encoding", "Chunked");

#Send the request
$sessionvar = $null
$lists = Invoke-WebRequest -Method Post -Uri $url -Headers $headers -Body $soapbody -SessionVariable sessionvar -Credential $creds

#Dump output
$xml = [xml]$lists.Content
$xml.Envelope.Body.GetListCollectionResponse.GetListCollectionResult.Lists | %{$_.List} | Select Title, ID | ft -AutoSize