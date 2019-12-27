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

    if (-not (isNotEmptyNull $companyIDs)) {
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
            (get-content $companyfile) -replace ",,,,,,","" |  Out-File $companyfile
        }
        $retVal += $NewCompany
    }

    return $retVal;

}
