# Verify file status #
$maxparalleljobs = 200
$continue        = $false
$filePath        = "c:\sids.txt" #make sure this file contains SIDs that needs to be resolved.

if((Test-Path $filePath) -eq $false)
{
    Write-Error -Message "File $filePath does not exist. Please correct file path before using this script. Exiting!"
    return
}

# Count of lines to show progress
$sidlines = Get-Content -Path $filePath
$totalLines = ( $sidlines | Measure-Object -Line).Lines

if(0 -ge $totalLines)
{
    Write-Error -Message "File $filePath empty?! This file must contain the SIDs you're intending to resolve! Exiting!"
    return    
}


#Script block which will be used by Powershell Jobs
$ADSidResolve = {
    param($sid)
    Write-Host "SID: $sid"
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    $objUser.Value
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

$alljobs = @()
$curLine = 0
foreach($line in $sidlines)
{
    #Trim off spaces from either sides of read in string
    $line = $line.Trim()

    ++$curLine;
    $continue = $false
    while($continue -eq $false)
    {
        $continue = ((Get-Job -State "Running").Count -lt $maxparalleljobs)
        if($continue)
        {
            $JobName = "PSJOB-SIDResolve-$line"    
            $alljobs += Start-Job -ScriptBlock $ADSIDResolve -Name $JobName -Credential $cred -ArgumentList $line
        }
        else
        {
            #Yield control for half a second
            #Start-Sleep -Milliseconds 10
        }
    }

    $PercentComplete = [math]::round((($curLine/$totalLines)*100),0)
    Write-Progress -Activity "Progress resolving SID... (Current line: $curLine of $totalLines)" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
}

#Wait for jobs to finish, in the end print the output
Write-Host "Waiting on jobs to finish..."
Get-Job | Wait-Job | Receive-Job

Remove-Variable alljobs,maxparalleljobs