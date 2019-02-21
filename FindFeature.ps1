Add-PSSnapin *SharePoint*

function WriteFeature($features, $tabs)
{
    if($null -ne $features)
    {
        ForEach($feature in $Features)
        {
            Write-Host $("`t" * $tabs)"-> Found Feature: Title: $($feature.GetTitle(1033)), DisplayName: $($feature.DisplayName)" -ForegroundColor Cyan
        }
    }
}

$FeatureDisplayName = "SiteLevelPolicy"

Write-Host -ForegroundColor Green "Script output in DisplayName and Title format..."
Write-Host "Looking for feature: $FeatureDisplayName" -ForegroundColor Yellow

$tab = 0
Write-Host $("`t" * $tab)"-> Farm"
$feature = Get-SPFeature -Farm -ErrorAction SilentlyContinue | Where-Object{$_.DisplayName -imatch $FeatureDisplayName}
WriteFeature $feature ($tab + 1)

ForEach($WebApp in Get-SPWebApplication)
{
    $tab = 1
    Write-Host $("`t" * $tab)"-> WebApp: $($WebApp.Url)"
    $feature = Get-SPFeature -WebApplication $WebApp.Url -ErrorAction SilentlyContinue | Where-Object{$_.DisplayName -imatch $FeatureDisplayName}
    WriteFeature $feature ($tab + 1)

    ForEach($Site in $WebApp.Sites)
    {
        $tab = 2
        Write-Host $("`t" * $tab)"-> Site: $($Site.Url)"
        $feature = Get-SPFeature -Site $Site.Url -ErrorAction SilentlyContinue | Where-Object{$_.DisplayName -imatch $FeatureDisplayName}
        WriteFeature $feature ($tab + 1)

        ForEach($Web in $Site.AllWebs)
        {
            $tab = 3
            Write-Host $("`t" * $tab)"-> Web: $($Web.Url)"
            $feature = Get-SPFeature -Web $Web.Url -ErrorAction SilentlyContinue | Where-Object{$_.DisplayName -imatch $FeatureDisplayName}
            WriteFeature $feature ($tab + 1)
        }#End ForEach
    }#End ForEach
}#End ForEach