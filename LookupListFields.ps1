Add-PSSnapin *SharePoint*
$weburl = "https://sharepoint.iso-ne.com/sites/odms"
$web = get-spweb $weburl

#Dump all lists in the web
Write-Host "`n>>>All lists in the web ...."
$web.lists | Select-Object Title, Id


#get list with this id
$listId = 'F9F87E49-FFD7-48E0-A869-FC324E808FFD'
$list = $web.lists | Where-Object{$_.Id -match $listId}

if($null -eq $list)
{
    Write-Error "`nFound no list list with id: $listId"
    return
}

#dump fields of this list
Write-Host "`n>>>List fields...."
$list.Fields | Select-Object Title, Id