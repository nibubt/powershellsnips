$ADSidResolve = {
    param($sid)
    Write-Host "SID: $sid"
    $objSID = New-Object System.Security.Principal.SecurityIdentifier($sid)
    $objUser = $objSID.Translate( [System.Security.Principal.NTAccount])
    $objUser.Value
}

$username = Read-Host -Prompt "Please enter username: "
$pwd = Read-Host -Prompt "Please enter your password: " -AsSecureString
$cred = New-Object System.Management.Automation.PSCredential($username,$pwd)
if($cred -eq $null)
{
    return;
}

$maxparalleljobs = 200
$continue        = $false
$filePath        = "c:\sids.txt" #make sure this file contains SIDs that needs to be resolved.

#Count of lines to show progress
$totalLines = (Get-Content -Path $filePath | Measure-Object -Line).Lines

$alljobs = @()
$reader = [System.IO.File]::OpenText("$filePath")
$curLine = 0
while($null -ne ($line = $reader.ReadLine())) 
{
    ++$curLine;
    $continue = $false
    while($continue -eq $false)
    {
        $continue = ((Get-Job -State "Running").Count -lt $maxparalleljobs)
        if($continue)
        {
            $JobName = "PSJOB--$line"    
            $alljobs += Start-Job -ScriptBlock $ADSIDResolve -Name $JobName -Credential $cred -ArgumentList $line
        }
        else
        {
            #Yield control for half a second
            Start-Sleep -Milliseconds 100
        }
    }

    $PercentComplete = [math]::round((($curLine/$totalLines)*100),0)
    Write-Progress -Activity "Progress resolving SID... (Current line: $curLine of $totalLines)" -Status "$PercentComplete% Complete:" -PercentComplete $PercentComplete
}

$reader.Close()

#Wait for jobs to finish, in the end print the output
Write-Host "Waiting on jobs to finish..."
Get-Job | Wait-Job | Receive-Job

#Write-Host "`nAll Jobs and their state..."
#$alljobs | Select-Object Name,State