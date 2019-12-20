function isNewWeek {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [bool] $retVal = ($date.DayOfWeek -eq "Saturday")
    if ($retval) { write-verbose "Current Date: $($date.ToShortDateString()) - $($MyInvocation.MyCommand): $retVal" }
    return $retVal
}

function isNewMonth {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [bool] $retVal =  ($Date.Day -eq 1)
    if ($retval) {   write-verbose "Current Date: $($date.ToShortDateString()) - $($MyInvocation.MyCommand): $retVal"}
    return $retval
}


function isNewQuarter {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [bool] $retVal =  (($Date.Day -eq 1) -and `
    (($Date.Month -eq 1) -or `
    ($Date.Month -eq 4) -or `
    ($Date.Month -eq 7) -or `
    ($Date.Month -eq 10)))
    if ($retval) { write-verbose "Current Date: $($date.ToShortDateString()) - $($MyInvocation.MyCommand): $retVal"}
    return $retVal
}

function isNewHalfYear {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [bool] $retVal =  (($date).Day -eq 1) -and `
    (($date.Month -eq 1) -or `
    ($date.Month -eq 7))
    if ($retval) { write-verbose "Current Date: $($date.ToShortDateString()) - $($MyInvocation.MyCommand): $retVal" }
    return $retVal
}

function isNewYear {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [bool] $retVal =  ($date.DayOfYear -eq 1)
    if ($retval) { write-verbose "Current Date: $($date.ToShortDateString()) - $($MyInvocation.MyCommand): $retVal" }
    return $retVal
}

function get-WeeklyDueDate {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    while ($Date.DayOfWeek -ne "Friday") {$date = $date.AddDays(1)}
    write-verbose "Current date: $date, the next end of week is $($date.month)/$($date.day)/$($date.year)"
    return $(Get-Date -year $date.Year -Month $date.Month -Day $date.Day -hour 17 -Minute 30 -second 0)
}

function get-MonthlyDueDate {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    $day = [DateTime]::DaysInMonth($date.Year, $date.Month)
    write-verbose "Current date: $date, the next end of month is $($date.month)/$day/$($date.year)"
    return $(Get-Date -year $date.Year -Month $date.Month -Day $day -hour 17 -Minute 30 -second 0)
}

function get-QuarterlyDueDate {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [int] $month = 0;
    [int] $day = 0;
    if (($date.Month -ge 1) -and ($date.Month -le 3)) {
        $month = 3
        $day = 31
    } elseif (($date.Month -ge 4) -and ($date.Month -le 6)) {
        $month = 6
        $day = 30
    } elseif (($date.Month -ge 6) -and ($date.Month -le 9)) {
        $month = 9
        $day = 30
    } elseif (($date.Month -ge 10) -and ($date.Month -le 12)) {
        $month = 12
        $day = 31
    } else {
        Write-Error "Unable to determine the date - Current reported date: $date"
    }
    write-verbose "Current date: $date, the next end of quarter is $month/$day/$($date.year)"
    return $(Get-Date -year $date.Year -Month $month -Day $day -hour 17 -Minute 30 -second 0)
}

function get-SemiAnnualDueDate {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    [int] $month = 0;
    [int] $day = 0;
    if (($date.Month -ge 1) -and ($date.Month -le 6)) {
        $month = 6
        $day = 30
    } elseif (($date.Month -ge 7) -and ($date.Month -le 12)) {
        $month = 12
        $day = 31
    } else {
        Write-Error "Unable to determine the date - Current reported date: $date"
    }
    write-verbose "Current date: $date, the next end of semi-anual period is $month/$day/$($date.year)"
    return $(Get-Date -year $date.Year -Month $month -Day $day -hour 17 -Minute 30 -second 0)
}

function get-AnnualDueDate {
    [CmdletBinding()]
    param(
    [datetime] $date = $(Get-Date)
    )
    write-verbose "Current date: $date, the next end of annual period is 12/31/$($date.year)"
    return $(Get-Date -year $date.Year -Month 12 -Day 31 -hour 17 -Minute 30 -second 0)
}

$VerbosePreference = "silent"

$ate = Get-Date -year 2019 -Month 1 -day 1
