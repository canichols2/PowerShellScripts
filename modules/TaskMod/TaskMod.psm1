$t2=@'
Folder: \Microsoft\Windows\Windows Error Reporting
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:QueueReporting}                           7/13/2018 8:53:26 AM   {Status:Ready}

Folder: \Microsoft\Windows\Windows Filtering Platform
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:BfeOnServiceStartTypeChange}              N/A                    {Status:Ready}

Folder: \Microsoft\Windows\Windows Media Sharing
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:UpdateLibrary}                            N/A                    {Status:Ready}

Folder: \Microsoft\Windows\WindowsColorSystem
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:Calibration Loader}                       N/A                    {Status:Ready}

Folder: \Microsoft\Windows\WindowsUpdate
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:Scheduled Start}                          7/14/2018 7:58:21 AM   {Status:Ready}
{TaskName*:sih}                                      7/13/2018 6:56:59 PM   {Status:Ready}

Folder: \Microsoft\Windows\Wininet
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:CacheTask}                                N/A                    {Status:Running}

Folder: \Microsoft\Windows\Work Folders
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:Work Folders Logon Synchronization}       N/A                    {Status:Ready}
{TaskName*:Work Folders Maintenance Work}            N/A                    {Status:Ready}

Folder: \Microsoft\Windows\Workplace Join
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:Automatic-Device-Join}                    N/A                    {Status:Ready}
{TaskName*:Recovery-Check}                           N/A                    {Status:Disabled}

Folder: \Microsoft\Windows\WwanSvc
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:NotificationTask}                         N/A                    {Status:Ready}

Folder: \Microsoft\XblGameSave
TaskName                                 Next Run Time          Status
======================================== ====================== ===============
{TaskName*:XblGameSaveTask}                          N/A                    {Status:Ready}
'@

# }
function Get-Cmd-ScheduledTasks
{
    param(
        $ComputerName,
        $TaskName
    )
    $expression = " schtasks "
    if($ComputerName){$expression += " /s $ComputerName "}
    # if($TaskName){$expression += " /TN $TaskName "}
    # $expression += " /v /FO LIST "
    
    $tasks = $(Invoke-Expression $expression) -join "`n" | ConvertFrom-String -TemplateContent $t2
    if($TaskName)
    {
        return $tasks | ?{$_.TaskName -like $TaskName}
    }
    else {
        return $tasks
    }
}


function Watch-Task {
    param (
        $ComputerName,
        $TaskName
    )
    while($true)
    {
        $Task = $(Get-Cmd-ScheduledTasks -ComputerName $ComputerName -TaskName $TaskName)[0]
        cls;
        switch ($Task.Status) {
            "ready" { Write-Host "$($Task.TaskName) is READY"       ;[console]::BackgroundColor = "blue";   [console]::ForegroundColor = "white"    }
            "running" { Write-Host "$($Task.TaskName) is RUNNING"   ;[console]::BackgroundColor = "yellow"; [console]::ForegroundColor = "black"    }
            "Disabled" { Write-Host "$($Task.TaskName) is DISABLED" ;[console]::BackgroundColor = "red";    [console]::ForegroundColor = "white"    }
            Default {Write-Host "No switch caught"}
        }
        Start-Sleep -Milliseconds 10
    }
}

function Get-RunningProcess {
    param (
        $ProcessName,
        $ComputerName="tdsb"
    )
    Get-Process -ComputerName $ComputerName -Name $ProcessName
}

function Watch-Process {
    param (
        $ProcessName,
        $ComputerName=$ENV:COMPUTERNAME
    )
    $currentBG = [console]::BackgroundColor
    $currentFG = [console]::ForegroundColor
    while($true)
    {
        $proc = Get-RunningProcess  $ProcessName $ComputerName
        cls
        if($proc)
        {
            [console]::BackgroundColor = "yellow";
            [console]::ForegroundColor = "black"
            Write-Host "$($ProcessName) is RUNNING";
        }
        else {
            [console]::BackgroundColor = $currentBG;
            [console]::ForegroundColor = $currentFG
            Write-Host "$($ProcessName) is NOT RUNNING";
        }
        Start-Sleep -Milliseconds 10
    }

}


# function Start-Cmd-Task {
#     param (
#         $ProcessName,
#         $ComputerName
#     )
#     $expression = " schtasks /Run "
#     if($ComputerName){$expression += " /s $ComputerName "}
# }

Export-ModuleMember -Function "Get-*"
Export-ModuleMember -Function "Watch-*"
Export-ModuleMember -Function "Start-*"
Export-ModuleMember -Function "Stop-*"