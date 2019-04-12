Add-PSSnapin *PowerShell*

foreach ($CurSite in Get-SPSite -Limit All) 
{
    Write-Host -ForegroundColor Red "CurSite: $($CurSite.Url)"
    foreach ($CurWeb in $CurSite.AllWebs) 
    {
        Write-Host -ForegroundColor Cyan "`tCurWeb: $($CurWeb.Url)"
        foreach ($CurList in $CurWeb.Lists) 
        {
            Write-Host -ForegroundColor Gray "`t`tList: $($CurList.DefaultViewUrl)"

            $iterateList = $false
            foreach($CurItem in $CurList.WorkflowAssociations | Where-Object{$_.RunningInstances -gt 0}) 
            {
                Write-Host -ForegroundColor DarkYellow "`t`t`tWorkflowName: $($CurItem.Name), Running Instances: $($CurItem.RunningInstances)"
                $iterateList = $true
            }

            if($iterateList -eq $true)
            {
                Write-Host "`t`t`t`tFinding all list items that has a workflow running..."
                foreach($CurListItem in $CurList.Items | Where-Object{$_.Workflows.Count -gt 0})
                {
                    Write-Host -ForegroundColor Yellow "`t`t`t`tItem: $($CurListItem.Title)"
                    foreach($CurWorkflow in $CurListItem.Workflows)
                    {
                        Write-Host -ForegroundColor DarkYellow "`t`t`t`t`tWorkflow: [$($CurWorkFlow.ParentAssociation.Name):$($CurWorkflow.InternalState)]"
                    }
                }

                $iterateList = $false
            }
        }
    }
}