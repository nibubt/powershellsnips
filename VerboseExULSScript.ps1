#Add the powershell snapin
Add-PSSnapin Microsoft.SharePoint.PowerShell

#Adds a bullet before an output string ideally
function Bullet
{
    Write-Host -ForegroundColor DarkCyan ">>" -NoNewline 
}

#Enable verboseex
Bullet
Write-Host "Enabling VerboseEx..."
Set-SPLogLevel -TraceSeverity VerboseEx

#log collection start time
$log_starttime = Get-Date

Bullet
$null = Read-Host -Prompt "Please press 'Enter' to stop VerboseEx log collection"

#log collection end time
$log_endtime = Get-Date

#Clear verboseex
Bullet
Write-Host "Disabling VerboseEx..."
Clear-SPLogLevel

#Write to file, Merge log files
Bullet
$log_filename = "$([Environment]::GetFolderPath("Desktop"))\MergedLog_$(Get-Date -F o | ForEach-Object {$_ -replace ':', '.'}).log"
Write-Host "Merging log files from '$($log_starttime)' to '$($log_endtime)' to log file: '$($log_filename)'"
Merge-SPLogFile -StartTime $log_starttime -EndTime $log_endtime -Path "$($log_filename)"

#Prompt to save merged SPLog file path to clipboard if needed
Bullet
if((Read-Host "Copy merged file path to clipboard [y/n]?")-ieq 'y')
{
    [Windows.Forms.Clipboard]::SetText($log_filename)
}