# Verify file status #
$filePath = "C:\sids.txt" #make sure this file contains SIDs that needs to be resolved.

if((Test-Path $filePath) -eq $false)
{
    Write-Error -Message "File $filePath does not exist. Please correct file path before using this script. Exiting!"
    return
}

# Count of lines to show progress
$sidlines = Get-Content -Path $filePath | ForEach-Object{$_.Trim()}
if($null -eq $sidlines)
{
    Write-Error -Message "File $filePath empty?! This file must contain the SIDs you're intending to resolve! Exiting!"
    return    
}


#Read in UserName and Password securely
$username = Read-Host -Prompt "Please enter username: "
$pwd = Read-Host -Prompt "Please enter your password: " -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($username,$pwd)
if($null -eq $cred)
{
    Write-Error -Message "Invalid credentials! Exiting!"
    return;
}

Write-Host -ForegroundColor Green "Loading SIDs from file: $filePath..."

$allsidObjs = New-Object System.Security.Principal.IdentityReferenceCollection

#Add all sids to IdentityReferenceCollection for batch translation later
$sidLines | ForEach-Object{$allsidObjs.Add((New-Object System.Security.Principal.SecurityIdentifier($_)))}

Write-Host -ForegroundColor Green "Translating SIDs..."
#BATCH TRANSLATE using System.Security.Principal.IdentityReferenceCollection.Translate call.
$allusers = $allsidObjs.Translate([System.Security.Principal.NTAccount])

#Code to display output
$mappedObjArray = @()
$curLine = 0
foreach($line in $sidlines)
{
    # Create a custom object to map SID to its username
    $mappedObjArray += New-Object -TypeName PSObject -Property @{SID = $line; UserName = $allusers[$curLine++]}
}

$curLine = 0
$mappedObjArray | Format-Table -AutoSize -Property @{Name="Index";Expression={$global:curLine;$global:curLine+=1}}, SID, UserName

Remove-Variable mappedObjArray,curLine,sidLines,allsidObjs,cred