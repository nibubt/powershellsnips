$web = "http://sp"
Write-Host "List event receivers for web $web" -ForegroundColor Blue -BackgroundColor White
$web = Get-SPWeb $web

$web.Lists | %{
    Write-Host "List: $($_.Title)"
    if($_.EventReceivers.Count -gt 0)
    {
        $_.EventReceivers | Select Name, Type, Assembly | %{
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