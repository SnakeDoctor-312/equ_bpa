[datetime] $DatumDate = Get-Date -year 2019 -Month 12 -Day 28 -Hour 0 -Minute 0 -Second 0

function QuartersSinceDatum {
    [CmdletBinding()]
    param(
        [OutputType([int32])]
        #[Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [datetime] $date)

    $date = $date | Get-Date -Hour 0 -Minute 0 -Second 0
    $timespan = $date - $DatumDate
    return [math]::Floor($timespan.totaldays / (13*7))
}

function QuarterNumber {
    [CmdletBinding()]
    param(
        [OutputType([int32])]
        #[Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [datetime] $date)

    return [math]::ceiling($(QuartersSinceDatum $date) %4 ) + 1
}

function EndofQuarter {
    [CmdletBinding()]
    param(
        [OutputType([datetime])]
        #[Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [datetime] $date)
    
    return $DatumDate.AddDays(-1 + $((QuartersSinceDatum $date)+1) * 13 * 7)

}

function StartofQuarter {
    [CmdletBinding()]
    param(
        [OutputType([datetime])]
        #[Parameter(Mandatory=$True)]
        [ValidateNotNullorEmpty()]
        [datetime] $date)
    
    return $DatumDate.AddDays($(QuartersSinceDatum $date) * 13 * 7)

}