﻿#Lists out event receivers of all lists within a web#
$web = "http://sp"
Write-Host "List event receivers for web $web" -ForegroundColor Blue -BackgroundColor White
$web = Get-SPWeb $web

$web.Lists | ForEach-Object{
    Write-Host "List: $($_.Title)"
    if($_.EventReceivers.Count -gt 0)
    {
        $_.EventReceivers | Select-Object Name, Type, Assembly | ForEach-Object{
            Write-Host "  |__Name: $($_.Name)" 
            Write-Host "  |__Type: $($_.Type)"
            Write-Host "  |__Assembly: $($_.Assembly)"
        }
        
    }
    else
    {
        Write-Host "  |__No event receiver found" -ForegroundColor Red
    }
}