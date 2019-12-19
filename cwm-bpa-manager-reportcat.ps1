#. "C:\Users\Mike\Desktop\equ_bpa\cwm-server-rest.ps1"
. "C:\Users\mdeliberto\Desktop\equ_bpa\cwm-server-rest.ps1"

$TaskFolder = "C:\Users\mdeliberto\Desktop\equ_bpa\Tasks"
$CompanyIDFile = "C:\Users\mdeliberto\Desktop\equ_bpa\CompanyIDs.csv"

#[string]$TaskFolder = "C:\Users\Mike\Desktop\equ_bpa\Tasks"
#$CompanyIDFile = "C:\Users\Mike\Desktop\equ_bpa\CompanyIDs.csv"

$VerbosePreference = "continue"
#$VerbosePreference = "SilentlyContinue"

function isNotEmptyFile {
    [CmdletBinding()]
    param(
    [OutputType([bool])]
    [Parameter(Mandatory=$True)]
    [ValidateNotNullorEmpty()]
    [string]$path)
    return (Test-path -Path $path -PathType Leaf) -and ((Get-Item $path).length -gt 0)
}
 
function isNotEmptyNull {
    [CmdletBinding()]
    param(
    [OutputType([bool])]
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="Array")]
    [System.Object[]]$array,
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="HashTable")]
    [System.Collections.Hashtable]$table,
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="OrderedDictionary")]
    [System.Collections.Specialized.OrderedDictionary]$ordereddictionary,
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="String")]
    [string]$string)
    switch ($PsCmdlet.ParameterSetName)
    {
        "Array" {return (($array -ne $null) -and ($array.count -ne 0))}
        "HashTable" {return -not ($table -ne $null) -and ($table.count -ne 0)}
        "OrderedDictionary" {return -not ($OrderedDictionary -ne $null) -and ($OrderedDictionary.count -ne 0)}
        "String" {return -not ($string -ne $null) -and ($string.length -ne 0)}
    }

}

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
    
    $retVal | fl
    $retVal  = $null
    [Company[]]$retVal  =@()
    
    $companyIDs = $null
    $companyIDs = import-csv -Path $companyfile
    
    isNotEmptyNull($companyIDs)
    if (-not $(isNotEmptyNull($companyIDs))) {
        write-error "$companyfile returned a null or empty hashtable"
    }
    
    Write-Verbose "Imported from file: $companyfile"
    $CompanyIDs | FT | Out-String | Write-Verbose
    Write-Verbose "Located $($CompanyIDs.Count) rows"
        
    foreach ($CompanyID in $companyIDs) {
        [Company]$NewCompany = [Company]::new($CompanyID.Company, $CompanyID.ID)
        
        #$CompanyJSON = $server.GetCompany($NewCompany.id)
        #$NewCompany.identifier = $CompanyJSON.identifier
        #$NewCompany.name = $CompanyJSON.name
        
        $ABBR =  $NewCompany.abbreviation
        $CompanyFile = $path + "\"+$ABBR + ".csv"
        if (isNotEmptyFile($companyFile)) {
            $NewCompany.path = $CompanyFile
        }
        $NewCompany | fl
        $retVal += $NewCompany
    }

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
                {$TaskDueDate = Get-date -Year 2019 -Month 11 -Day 30 -Hour 17 -Minute 30 -Second 0}
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

$Companies = $null
$Companies.Count
$Companies = Load-CompanyData $CompanyIDFile $TaskFolder

#$Companies | fl

$Companies.Count

foreach ($company in $Companies) {
    #$Companies | fl
   # read-host “Press ENTER to continue...”
    #$company.Path
   # $tasks = import-csv $company.Path
   # $tasks | ft
    #$Company | fl
    #foreach ($Task in $tasks) {
     #   if ($task.Task -ne "") {
      #      if ($Task.Freq -eq "Weekly") {
       #         $newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")

                	
                if ($Company.id -gt 0) {
                $Server.CreateTicket_NoDate("1. Environment Health Summary", "None at this time", $($company.id), "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("2. Best Practice Administration (BPA) Tasks Summary", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("3. Backup Job Status", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("4. Operating System and Software Lifecycle", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("5. Server Environment", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("6. Desktop Environment", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("7. Virus Protection Status", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
                $Server.CreateTicket_NoDate("8. Network Device Status", "None at this time", $company.id, "", 71, 423, 0, 1043, 0)
        }
        #    }
           # if ($Task.Freq -eq "Monthly") {
            #    $newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
             #   $Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
            #}
            
      #  }
    #}
}

    




#$a = $BPAReport_Type.Monthly
<#


$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")




foreach ($file in $files) {
    
}


#>