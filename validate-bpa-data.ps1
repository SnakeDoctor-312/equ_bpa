. "$PSScriptRoot\cwm-server-rest.ps1"
. "$PSScriptRoot\cwm-company.ps1"
. "$PSScriptRoot\bpa-date-functions.ps1"
. "$PSScriptRoot\bpa-validator-functions.ps1"
. "$PSScriptRoot\bpa-task.ps1"


$TaskFolder = "$PSScriptRoot\Tasks"
$CompanyIDFile = "$PSScriptRoot\CompanyIDs.csv"

#$VerbosePreference = "continue"
#$WarningAction Inquire
$VerbosePreference = "SilentlyContinue"


$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")
$server.connect()

$Companies = Load-CompanyData $CompanyIDFile $TaskFolder

foreach ($company in $Companies) {
    #
    
    #write-host $company.path
    $tasks = Load-ClientTasks $company.path
    foreach ($task in $tasks) {
        
        if ($Task.Frequency -eq "Weekly") {
            #$company.abbreviation
            #$task
            #$Task | FL
            #$newTask = [Task]::new($task.Summary, $Task.Frequency, $Task.Budget, $Task.Engineer, $Task.Description, $Task.Category)
                
            #$newtask|FL   
            #$Server.CreateTicket($newTask.Summary, $NewTask.Description , $company.id, $newTask.Engineer, 71, $newTask.Frequency, $newTask.Category, 1022, $newtask.DueDate, $newTask.budget)
        }
        if ($Task.Frequency -eq "Monthly") {
            #$company.abbreviation
            #$task
            #$newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
            #$Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
        }
        if ($Task.Frequency -eq "Quarterly") {
            #$company.abbreviation
            #$task
            #$newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
            #$Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
        }
        if ($Task.Frequency -eq "SemiAnnual") {
            #$company.abbreviation
            #$task
            #$newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
            #$Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
        }
        if ($Task.Frequency -eq "Annual") {
            #$company.abbreviation
            #$task
            #$newTask = [Task]::new($task.Task, $Task.Freq, $Task.Budget, "System", $Task.Engineer, "None")
            #$Server.CreateTicket($newTask.Summary, "None at this time", $company.id, $newTask.owner, 71, $newTask.Type, $newTask.subtype, 1022, $newtask.DueDate, $newTask.budget)
        }

    }
}