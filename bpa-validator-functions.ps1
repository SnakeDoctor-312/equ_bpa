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
    #[Parameter(Position=0, Mandatory=$True,ParameterSetName="Double")]
    #[double]$double,
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="HashTable")]
    [System.Collections.Hashtable]$table,
    [Parameter(Position=0, Mandatory=$True,ParameterSetName="OrderedDictionary")]
    [System.Collections.Specialized.OrderedDictionary]$ordereddictionary)
    switch ($PsCmdlet.ParameterSetName)
    {
        "Array" {return (($array -ne $null) -and ($array.count -ne 0))}
        "HashTable" {return -not ($table -ne $null) -and ($table.count -ne 0)}
        #"Double" {return -not (dDouble -ne $null)}
        "OrderedDictionary" {return -not ($OrderedDictionary -ne $null) -and ($OrderedDictionary.count -ne 0)}
    }

}

function isEmptyNullWhiteSpace {
    [CmdletBinding()]
    param(
    [OutputType([bool])]
    [Parameter(Position=0, Mandatory=$True)]
    [string]$in)
    return !([String]::IsNullOrEmpty($in)  -or [String]::IsNullOrWhiteSpace($in))
}

function isNotEmptyNullWhiteSpace {
    [CmdletBinding()]
    param(
    [OutputType([bool])]
    [Parameter(Position=0, Mandatory=$True)]
    [string]$in)
    return (-not (isEmptyNullWhiteSpace $in))
}

<##
function isEmptyNull {
    [CmdletBinding()]
    param(
    [OutputType([bool])]
    [Parameter(Position=0, Mandatory=$True)]
    $arg)
    return $(-not $(isNotEmptyNull $arg))
}##>