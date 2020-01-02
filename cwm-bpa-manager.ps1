. "$PSScriptRoot\cwm-server-rest.ps1"
. "$PSScriptRoot\cwm-company.ps1"
. "$PSScriptRoot\bpa-date-functions.ps1"
. "$PSScriptRoot\bpa-validator-functions.ps1"
. "$PSScriptRoot\bpa-task.ps1"

#This is the folder where the client task files live
$TaskFolder = "$PSScriptRoot\Tasks"
#This is where the companyID file live
$CompanyIDFile = "$PSScriptRoot\CompanyIDs.csv"

#$VerbosePreference = "continue"
#$WarningAction Inquire
$VerbosePreference = "SilentlyContinue"

#set the varibles below to true to create tickets of a particular interval on a non scheduled day
[bool] $forceWeekly = $false
[bool] $forceMonthly = $false
[bool] $forceQuarterly = $false
[bool] $forceSemiAnnual = $false
[bool] $forceAnnual = $false
#Set this to true to create all tickets, this ovverides the above invidual interval settings
[bool] $forceAll = $false

if ($forceAll) {
    $forceWeekly = $forceMonthly = $forceQuarterly = $forceSemiAnnual = $forceAnnual = $true
}

#If you need to create all of the tickets for one/multiple customers update the value of the variable below:
#Ex 1 (Create all AEP tickets)
#[string] $onboardCustomer = "AEP"
#Ex 2 (Create all AEP & FEC tickets)
#[string] $onboardCustomer = "AEP,FEC"

[string] $onboardCustomer = ""

$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")
$null = $server.connect()

#This loads & verifies the comapny daata in the CompanyIDs.csv file
$Companies = Load-CompanyData $CompanyIDFile $TaskFolder

#This loop iterates through the list of companies in the companyIDs.csv files for ticket creation
foreach ($company in $Companies) {
    #This loads $ verifies the task data in the client tasks file located at .\tasks\XXX.csv
    $tasks = Load-ClientTasks $company.path
    #This loop iterates throught the tasks in the client tasks file located at .\tasks\XXX.csv
    foreach ($task in $tasks) {
        #If the there are no onboarding customers listed proceed with normal execution
        if ($onboardCustomer -eq "") {
            #If it is a new week (Saturday) or weeklies are being forced
            if ($(isNewWeek) -or $forceWeekly) {
                #If it is a weekly task
                if ($Task.Frequency -eq "Weekly") {
                    #Create Ticket
                    $Server.CreateBPAReportTicket($company.id, $Task)
                }
            }
            #if it is the first of the month or monthlies are being forced
            if ($(isNewMonth) -or $forceMonthly) {
                #if it is a monthly task
                if ($Task.Frequency -eq "Monthly") {
                    #Create ticket
                    $Server.CreateBPAReportTicket($company.id, $Task)
                }
            }
            #If it is a the first day of the quarter or quarterlies are being forced
            if ($(isNewQuarter) -or $forceQuarterly) {
                #if it is a quarterly task
                if ($Task.Frequency -eq "Quarterly") {
                    #Create ticket
                    $Server.CreateBPAReportTicket($company.id, $Task)
                }
            }
            #If it is the first day of Q1 or Q3 or semi annuals are being forced
            if ($(isNewHalfYear) -or $forceSemiAnnual) {
                #If it is a semi annual task
                if ($Task.Frequency -eq "SemiAnnual") {
                    #Create ticket
                    $Server.CreateBPAReportTicket($company.id, $Task)
                }
            }
            #If it is the first day of the eyar or annuals are being forced
            if ($(isNewYear) -or $forceAnnual) {
                #If it is a annual task
                if ($Task.Frequency -eq "Annual") {
                    #Create ticket
                    $Server.CreateBPAReportTicket($company.id, $Task)
                }
            }
        #check to see if the client abbreviation is in the $onboardCustomer variable
        } elseif ($onboardCustomer -like "*$($company.abbreviation)*") {
            #Create all tickets
            $Server.CreateBPAReportTicket($company.id, $Task)
        }
    }
}