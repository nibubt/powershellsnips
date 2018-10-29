<# .SYNOPSIS
      This powershell script enumerates all the 2010 Workflows published in the SharePoint Farm

.NOTES
   FileName: ListAllWFinFarm.ps1
   
 #>
Add-PSSnapin Microsoft.SharePoint.Powershell
$Logfile = "c:\temp\scripttest\SP2010WF.txt"

[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SharePoint")
[System.Reflection.Assembly]::LoadWithPartialName("System.Xml")

$farm = [Microsoft.SharePoint.Administration.SPFarm]::Local
[Microsoft.SharePoint.SPSecurity]::RunWithElevatedPrivileges( {
        $total2010WF = 0
        $running2010WfInstance = 0
        $webApps = Get-SPWebApplication
        Write-Host "******Below is the list of all Workflows in the Farm******" -BackgroundColor Yellow -ForegroundColor DarkMagenta
        foreach ($webApp in $webApps) {
            $siteCol = $webApp.Sites               
            foreach ($site in $siteCol) {
         
                $webs = $site.AllWebs                                    
                foreach ($web in $webs) {              
             

                    #Listing 2010 Workflows
                    $webWfAssocs = $web.WorkflowAssociations                         
                    if ($webWfAssocs.Count -gt 0) {                 
                        "Below are 2010 Workflows published on: " + $web.Url | Out-File $Logfile -Append
                        "Total Site Workflows:" + $webWfAssocs.Count | Out-File $Logfile -Append
                        $total2010WF += $webWfAssocs.Count
                        foreach ($wfAssoc in $webWfAssocs) {
                            "Workflow Name:" + $wfAssoc.Name | Out-File $Logfile -Append
                            "Running Instances:" + $wfAssoc.RunningInstances | Out-File $Logfile -Append
                            $running2010WfInstance += $wfAssoc.RunningInstance


                        }
                    }
                    $listCol = $web.Lists
                    if ($listcol.Count -gt 0) {     
                                                   
                        #insert temp array to call list and do work against temp aray instead of list collection directly otherwise we get the enumeration error when we move to next list after editOut-File$Logfile
                                                   
                        $thearrayoflistguids = @()
                                                                                                      
                        #populate the listrray with list guids                                                         
                        foreach ($list in $listcol) {
                            $thearrayoflistguids += $list.id
                        }
                        #items in array
                        #write-host "we have " $thearrayoflistguids

                        #pipe ID's get list objects from by ID


                        foreach ($listid in $thearrayoflistguids) {                                                                 
                                                                                  
                            $list = $listCol | ? {$_.id -match $listid}
                            #prove we found list
                            #  write-host "current list id " $list.id
                            # write-host "current list name " $list.title
                                                                                  
                            $wfAssocs = $list.WorkflowAssociations
                      
                                             
                            if ($wfAssocs.Count -gt 0) {
                                # Write-Host "WebApplication Name: " $webApp.Name -ForegroundColor Magenta
                                # Write-Host "SPSite URL: " $site.Url -ForegroundColor Magenta 
                                # Write-Host "SPWeb URL: " $web.Url -ForegroundColor Magenta
                                "List Name:" + $list.Title | Out-File $Logfile -Append
                                "Total 2010 Workflow Published on List:" + $wfAssocs.Count | Out-File $Logfile -Append
                                $total2010WF += $WfAssocs.Count
                                $tempList = New-Object "System.Collections.Generic.List``1[System.Object]"                     
                                foreach ($wfAssoc in $wfAssocs) {
                                    if ($wfAssoc.Name -like "*Previous Version*") { 
                                        #  write-host "templist add"
                                        $tempList.Add($wfAssoc)
                                    }
                                    "Workflow Name:" + $wfAssoc.Name | Out-File $Logfile -Append
                                    "Running Instances:" + $wfAssoc.RunningInstances | Out-File $Logfile -Append
                                    $running2010WfInstance += $wfAssoc.RunningInstance

                                    #   write-host "whats in templist=" $templist
                                }
                                #   write-host "outside loop"
                                #  write-host "contents of templist" $tempList
                                #{
                                foreach ($wf in $tempList) { 

                                    #  write-host "hit"
                                    $list.RemoveWorkflowAssociation($wf);
                                    #  $list.update()
                                }

                                #}
                                "================================================================="   | Out-File $Logfile -Append                                                             
                            }                                                                             
                        }   
                    }
                    $web.Dispose()                                                                 
                }
                $site.Dispose()
            }
        }

        Write-Host "Total 2010 Workflows:" $total2010WF -Verbose
        Write-Host "Total Running instances of 2010 Workflows:" $running2010WfInstance -Verbose
        Write-Host "Logs written at " $Logfile -ForegroundColor Magenta
    })
