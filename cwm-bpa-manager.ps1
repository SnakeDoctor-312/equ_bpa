#. "C:\Users\Mike\Desktop\BPA Manager\cwm-server-rest.ps1"

$TaskFolder = "C:\Users\mdeliberto\Desktop\BPA Manager\Tasks"
$CompanyIDFile = "C:\Users\mdeliberto\Desktop\BPA Manager\CompanyIDs.csv"

#$VerbosePreference = "continue"
$VerbosePreference = "SilentlyContinue"

function Load-CompanyIDs {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    Param (
        [validateScript({ (Test-path -Path $_ -PathType Leaf) -and ((Get-Item $_).length -gt 0) })]
        [string] $companyfile)
    
    $retVal = [ordered]@{}
    
    $companyIDs = import-csv -Path $companyfile
    if (($companIDs -eq $null) -or ($companIDs.count -eq 0)) {
        write-error "$companyfile returned a null or empty hashtable"
    }
    
    Write-Verbose "Imported from file: $companyfile"
    $CompanyIDs | FT | Out-String | Write-Verbose
    Write-Verbose "Located $($CompanyIDs.Count) rows"
        
    $companyIDs | % { $retVal[$_.Company] = $_.ID }
    return $retVal

}

enum TaskFrequency {
        Weekly =  416;
        Monthly = 417;
        Quarterly =  418;
        SemiAnnual = 419;
        Annual =    420;
        Daily   =   421;
}

enum TaskCatergory {
        System      = 563
        Application = 564
        Network     = 565
        Desktop     = 566
        Security    = 567
        Cloud       = 568
        Storage     = 569
}


class TaskSet {
    [string]$clientID

    TaskSet([string] $ClientName, [Task[]]$taskList) {
        $this.clientID = $ClientName;
        $this.tasks = $taskList;
    }

}

class Task {
    [string]$Summary
    [double]$Budget
    [uint32]$Type
    [uint32]$subtype
    [string]$owner
    [string]$DueDate

   $BPAReport_Type =  @{
        Weekly =  416;
        Monthly = 417;
        Quarterly =  418;
        SemiAnnual = 419;
        Annual =    420;
        Daily   =   421;
    }

    $BPAReport_SubType =  @{
        System      = 563
        Application = 564
        Network     = 565
        Desktop     = 566
        Security    = 567
        Cloud       = 568
        Storage     = 569
    }


    Task([string]$Summary, [String]$Frequency, [double]$Budget, [string]$subtype,[string]$owner)     {
        [datetime]$TaskDueDate = Get-date -Year 2019 -Month 12 -Date 28 -Hour 17 -Minute 30 -Second 0;
        $this.Summary = $Summary;
        $this.type = $this.BPAReport_Type[$Frequency];
        $this.Budget = $budget;
        $this.subtype = $this.BPAReport_Subtype[$subtype]
        $this.owner = $owner;

        switch($this.Type) {
            416 {$TaskDueDate = Get-date -Year 2019 -Month 10 -Day 09 -Hour 17 -Minute 30 -Second 0}
            417 {$TaskDueDate = Get-date -Year 2019 -Month 10 -Day 31 -Hour 17 -Minute 30 -Second 0}
            418 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            419 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            420 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            default {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
        }
        #$TaskDuedate
        $this.DueDate = $($TaskDueDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
        #write-host $TaskDuedate $frequency $this.DueDate
        #2019-09-14T17:59:51Z
    }
}

$CompanyIDs = Load-CompanyIDs $CompanyIDFile



#$a = $BPAReport_Type.Monthly
<#


$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")


$server.connect()

foreach ($file in $files) {
    $ClientName = [uint32]$file.name.substring(0,$file.name.length-4)
    $ClientName
    #$file.FullName
    $tasks = import-csv $file.FullName
    foreach ($Task in $tasks) {
        if ($task.Task -ne "") {
            if ($Task.Freq -eq "Weekly") {
                $newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer)
                $Server.CreateTicket($newTask.Summary, "None at this time", $ClientName, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
            }
            
        }
    }
}


#>