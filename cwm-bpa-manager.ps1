. "$PSScriptRoot\cwm-server-rest.ps1"
. "$PSScriptRoot\bpa-date-functions.ps1"
. "$PSScriptRoot\bpa-validator-functions.ps1"

$TaskFolder = "$PSScriptRoot\Tasks"
$CompanyIDFile = "$PSScriptRoot\CompanyIDs.csv"

#$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"

class Company {
    [string]$abbreviation
    [uint32]$id
    [string]$identifier
    [string]$name
    [string]$path

    Company([string] $abbreviation, [uint32]$id) {
        $this.abbreviation = $abbreviation
        $this.id = $id
    }
   
} 

function Load-CompanyData {
    [CmdletBinding()]
    [OutputType([Company[]])]
    Param (
        [validateScript({ isNotEmptyFile($_) })]
        [string] $companyfile,
        [validateScript({ Test-path -Path $_ -PathType Container })]
        [string] $path)
    
    [Company[]]$retVal  =@()
    
    $companyIDs = import-csv -Path $companyfile
    
    if (isEmptyNull($companyIDs)) {
        write-error "$companyfile returned a null or empty hashtable"
    }
    
    Write-Verbose "Imported from file: $companyfile"
    $CompanyIDs | FT | Out-String | Write-Verbose
    Write-Verbose "Located $($CompanyIDs.Count) rows"
        
    foreach ($CompanyID in $companyIDs) {
        [Company]$NewCompany = [Company]::new($CompanyID.Company, $CompanyID.ID)
        
        $CompanyJSON = $server.GetCompany($NewCompany.id)
        
        $NewCompany.identifier = $CompanyJSON.identifier
        $NewCompany.name = $CompanyJSON.name
        
        $ABBR =  $NewCompany.abbreviation
        $CompanyFile = $path + "\"+$ABBR + ".csv"
        if (isNotEmptyFile $companyFile) {
            $NewCompany.path = $CompanyFile
        }
        $retVal += $NewCompany
    }

    return $retVal;

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
    [TaskFrequency]$Type
    [TaskCatergory]$subtype
    [string]$owner
    [string]$DueDate
    [string]$Description

    Task([string]$Summary, [String]$Frequency, [double]$Budget, [string]$subtype,[string]$owner,[string]$InitialDescription)     {
        [datetime]$TaskDueDate = Get-date -Year 2019 -Month 12 -Date 28 -Hour 17 -Minute 30 -Second 0;
        $this.Summary = $Summary;
        $this.type = [TaskFrequency]$Frequency
        $this.Budget = $budget;
        $this.subtype = [TaskCatergory]$subtype
        $this.owner = $owner;

        switch($this.Type) {
            ([TaskFrequency]::Weekly)
                {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 20 -Hour 17 -Minute 30 -Second 0}
            ([TaskFrequency]::Monthly)
                 {$TaskDueDate = Get-date -Year 2019 -Month 11 -Day 30 -Hour 17 -Minute 30 -Second 0}
            ([TaskFrequency]::Quarterly)
                 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            ([TaskFrequency]::SemiAnnual)
                 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            ([TaskFrequency]::Annual)
                 {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
            default
                {$TaskDueDate = Get-date -Year 2019 -Month 12 -Day 28 -Hour 17 -Minute 30 -Second 0}
        }
        $this.DueDate = $($TaskDueDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
        #write-host $TaskDuedate $frequency $this.DueDate
        #2019-09-14T17:59:51Z
    }
}


$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")
$server.connect()


$Companies = Load-CompanyData $CompanyIDFile $TaskFolder

$Companies | ft

foreach ($company in $Companies) {
    $tasks = import-csv $company.Path
    foreach ($task in $tasks) {
        if ($task -ne "") {
            if (isNewWeek) {
                #close all weeklies
                #Create Weelkies
            }
            if (isNewMonth) {
                #close all weeklies
                #Create Weelkies
            }
            if (isNewQuarter) {
                #close all weeklies
                #Create Weelkies
            }
            if (isNewHalfYear) {
                #close all weeklies
                #Create Weelkies
            }
            if (isNewYear) {
                #close all weeklies
                #Create Weelkies
            }
        } else {
            ###
        }
    }
}
    <##foreach ($Task in $tasks) {
        if ($task.Task -ne "") {
            if ($Task.Freq -eq "Weekly") {
                $newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
                $Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
            }
           # if ($Task.Freq -eq "Monthly") {
            #    $newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
             #   $Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
            #}
            
        }
    }
}

    




#$a = $BPAReport_Type.Monthly
<#


$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")




foreach ($file in $files) {
    
}


#>