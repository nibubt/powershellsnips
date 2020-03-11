## SharePoint DLL
[void][System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
$webApplicationURL = "http://nt-sp2013-26"
$out = "C:\MissingFeatures.csv"

# Farm features
$farmFeatures = [Microsoft.SharePoint.Administration.SPWebService]::AdministrationService.Features
foreach ($feature in $farmFeatures) 
{
    if ($feature.definition -eq $null) 
    {
        "Missing farm feature: " + $feature.DefinitionId + " in " + $feature.parent | Out-File $out -Append
        write-host "Missing farm feature:"
        write-host $feature.DefinitionId
        write-host $feature.parent
    }
    else
    {
        #Write-Host "Farm Feature: $($feature.Definition.DisplayName)"
    }
}

# Web app features
$webApp = Get-SPWebApplication $webApplicationURL
if ($webApp -ne $null)
{
    "Web Application : " + $webApp.Name | Out-File $out -Append
    foreach ($feature in $webApp.features) 
    {
        if ($feature.definition -eq $null) 
        {
            "Missing web app feature: " + $feature.DefinitionId + " in " + $feature.parent | Out-File $out -Append
            write-host "Missing web app feature: "
            write-host $feature.DefinitionId
            write-host $feature.parent
        }
        else
        {
            #Write-Host "WebApp Feature: $($feature.Definition.DisplayName)"
        }

    }
    # Site collection and web features
    foreach ($siteColl in $webApp.Sites)
    {
        if ($siteColl -ne $null)
        {
            $siteColl.Url | Out-File $out -Append
            ## get the missing site collection features
            foreach ($feature in $siteColl.features) 
            {
                if ($feature.definition -eq $null)
                {
                    "Missing site feature: " + $feature.DefinitionId + " in " + $feature.parent | Out-File $out -Append
                    write-host "Missing site feature:"
                    write-host $feature.DefinitionId
                    write-host $feature.parent
                }
                else
                {
                    #Write-Host "Site Collection Feature: $($feature.Definition.DisplayName)"
                }
            }

            $webs = $siteColl | get-spweb -limit all
            foreach ($web in $webs)
            {
                foreach ($feature in $web.features)
                {
                    if ($feature.definition -eq $null)
                    {
                        "Missing web feature: " + $feature.DefinitionId + " in " + $feature.parent | Out-File $out -Append
                        write-host "Missing web feature: "
                        write-host $web.url
                        write-host $feature.DefinitionId
                        write-host $feature.parent
                    }
                    else
                    {
                        #Write-Host "Web Feature: $($feature.Definition.DisplayName)"
                    }
                }
            }
            $siteColl.Dispose()
        }
        else
        {
            Write-Host "$siteColl does not exist"
        }
    }
}
else
{
    Write-Host "$webApplicationURL does not exist, check the WebApplication name"
}