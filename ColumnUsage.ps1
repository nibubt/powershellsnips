###This script lists out all site columns containing $ColName###
Add-PSSnapin "Microsoft.SharePoint.PowerShell"   
$ColName = "Create"
$ColUsageCount = 0

Write-Host "Looking for usage of column containing word: '$ColName'" -BackgroundColor Blue

# Go through all content types under a web to list column usage
Get-SPWebApplication | %{$_.Sites} | %{`

    #Loop through webs
    foreach ($web in $_.AllWebs)  
    {
        Write-Host "Searching Web: $($web.Url)..."
        $AllCTs = $web.ContentTypes
        foreach($CT in $AllCts)
        {
            $Links = $CT.FieldLinks | ? {$_.Name -imatch $ColName}
            if($Links) {Write-Host "`t|___Used in CT: $($CT.Name)" -ForegroundColor Gray}
            foreach($Lnk in $Links)
            {
                ++$ColUsageCount
                Write-Host "`t`t|__Name: $($Lnk.DisplayName) ID: $($Lnk.Id)" -ForegroundColor DarkGray
            }
        }
        $web.Dispose()  
    }
}
Write-Host "`nFound $ColUsageCount usages of columns containing word '$ColName'." -ForegroundColor Yellow
