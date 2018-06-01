#Script to list out content type usage, good to figure who's using a content type, is it a list or web#
Add-PSSnapin "Microsoft.SharePoint.PowerShell"
$ctName = "Emp"
$CTListUsageCount = 0
$CTSiteUsageCount = 0
 
Write-Host "Looking for content type '$ctName'"

# Go through all webapps, sites and webs to list a content type usage
Get-SPWebApplication | ForEach-Object{$_.Sites} | ForEach-Object{`
 
    #Loop through webs
    foreach ($web in $_.AllWebs)  
    { 
        $CTs = $web.ContentTypes | Where-Object{$_.Name -eq $ctName}
        
        foreach($ct in $CTs)
        {
            $usages = [Microsoft.SharePoint.SPContentTypeUsage]::GetUsages($ct)
            if($usages)
            {
                Write-Host "Found usage in Web: '$($web.Url)' for content type: '$($ct.Name)'" -BackgroundColor Gray
            }

            foreach($usage in $usages)
            {
                if($usage.IsUrlToList)
                {
                    ++$CTListUsageCount
                    Write-Host "`tUsed in List: $($usage.Url)"
                }
                else
                {
                    ++$CTSiteUsageCount
                    Write-Host "`tUsed in Site: $($usage.Url)"
                }
            }

        }

        $web.Dispose()  
    }
}
Write-Host "`nFound $CTListUsageCount list and $CTSiteUsageCount site usages of content type '$ctName'." -ForegroundColor Green