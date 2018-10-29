# Powershell script shows how to access Control Panel Items using PowerShell #

Show-ControlPanelItem 
Show-ControlPanelItem Display

#Get the control panel display object
$Display = Get-ControlPanelItem *User*
#Dump display object properties
$Display | Format-List
Show-ControlPanelItem $Display