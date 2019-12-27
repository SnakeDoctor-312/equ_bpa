. "$PSScriptRoot\bpa-date-functions.ps1"

enum TaskFrequency {
        Weekly =  416;
        Monthly = 417;
        Quarterly =  418;
        SemiAnnual = 419;
        Annual =    420;
        Daily   =   421;
}

enum TaskCategory {
        System      = 563
        Application = 564
        Network     = 565
        Desktop     = 566
        Security    = 567
        Cloud       = 568
        Storage     = 569
}

class Task {
    [string]$Summary
    [double]$Budget
    [TaskFrequency]$Frequency
    [TaskCategory]$Category
    [string]$owner
    [string]$DueDate
    [string]$Description

    Task([string]$Summary, [string]$Frequency, [double]$Budget, [string]$owner,[string]$InitialDescription, [string]$Category)     {
        [datetime]$TaskDueDate = Get-Date -Hour 17 -Minute 30 -Second 0;
        
        [bool] $parameterIssue = $false
        
        $this.Frequency = [TaskFrequency]$Frequency
        $this.Category = [TaskCategory]$Category

        $castBudget = [double]::Parse($Budget)
        if ($castBudget -lt 0) {
            Write-verbose "Budget is $castBudget. Changing to 0"
            $this.Budget = 0
        } else {
            $this.Budget = $castBudget
        }

        switch($this.Type) {
            ([TaskFrequency]::Weekly)
                {$TaskDueDate = get-WeeklyDueDate}
            ([TaskFrequency]::Monthly)
                 {$TaskDueDate = get-MonthlyDueDate}
            ([TaskFrequency]::Quarterly)
                 {$TaskDueDate = get-QuarterlyDueDate}
            ([TaskFrequency]::SemiAnnual)
                 {$TaskDueDate = get-SemiAnnualDueDate}
            ([TaskFrequency]::Annual)
                 {$TaskDueDate = get-AnnualDueDate}
            default
                {$TaskDueDate = Get-date -Hour 17 -Minute 30 -Second 0}
        }
        $this.DueDate = $($TaskDueDate).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ");
    }
}

function Load-ClientTasks {
    [CmdletBinding()]
    [OutputType([Task[]])]
    Param (
        [validateScript({ isNotEmptyFile($_) })]
        [string] $clientTasks)
    
    [Task[]]$retVal  =@()
    
    $taskImport = import-csv -Path $clientTasks
    
    if (-not (isNotEmptyNull($taskImport))) {
        write-error "$clientTasks returned a null or empty hashtable"
    }
    
    Write-Verbose "Imported from file: $clientTasks"
    $taskImport | FT | Out-String | Write-Verbose
    Write-Verbose "Located $($taskImport.Count) rows"
    
    foreach ($taskRow in $taskImport) {
        if (($taskRow.Summary -eq "") -or `
            ($taskRow.Budget -eq "") -or `
            ($taskRow.Catergory -eq "") -or `
            ($taskRow.Description -eq "") -or `
            ($taskRow.Freq -eq "") -or `
            ($taskRow.Engineer-eq "")) {
            break;    
        } else {
           [Task]$NewTask = [Task]::new($taskRow.Summary, [TaskFrequency]$taskRow.Freq, $taskRow.Budget, $taskRow.engineer, $taskRow.Description, [TaskCategory]$taskRow.Catergory)
                  
            if ($newTask -ne $null) {
                $retVal += $newTask
            }
        }
        $A | out-null
    }

    return $retVal;

}