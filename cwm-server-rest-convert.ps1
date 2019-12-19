class CWServer {
    [string]$LoginCompanyId
    [string]$ConnectwiseSite
    [string]$CallingCompanyInfoURL
    [string]$APIRequestURL
    [string]$SupportedVersion = "v2019.4"

    #APIKEys
    [string]$PublicKey
    [string]$PrivateKey
    #Integration specific ID created on connectwise developer network for "Powershell Ticket Manager", created by: mdeliberto@eqinc.com
    [string]$ClientID = "5215955a-87d4-4b36-bcd3-df0232508a41"
    #Creds
    $AuthHeader =@{}
    $JSONHeader =@{}
   
    #CallingCompanyInfo
    [string]$Codebase
    [string]$CompanyID
    [string]$CompanyName
    [bool]$IsCloud
    [string]$SiteUrl
    [string]$VersionCode
    [string]$VersionNumber



    CWServer([string]$LoginCompanyId, [string]$ConnectwiseSite, [string] $public, [string] $private) {
        $this.LoginCompanyId = $LoginCompanyId
        $this.ConnectwiseSite = $ConnectwiseSite
        $this.CallingCompanyInfoURL = "https://" + $ConnectWiseSite + "/login/companyinfo/" + $LoginCompanyId
        $this.StoreAPIKeys($public, $private)
    }
    
    CWServer([string]$LoginCompanyId, [string]$ConnectwiseSite) {
        $this.LoginCompanyId = $LoginCompanyId
        $this.ConnectwiseSite = $ConnectwiseSite
        $this.CallingCompanyInfoURL = "http://" + $ConnectWiseSite + "/login/companyinfo/" + $LoginCompanyId
    }

    [bool]GetCallingComanyInfo() {
        $Response = Invoke-RestMethod -Method Get -Uri $this.CallingCompanyInfoURL -Headers $this.AuthHeader -UseBasicParsing
        if ($Response -ne $null) {
            Write-host $Response
            $this.ParseCallingCompanyInfo($Response)
            $this.CreateAPIRequestURL()
            return $true
        }
        write-error $Response
        return $false
    }
    
    [void]ParseCallingCompanyInfo($Response) {
        $this.Codebase = $Response.Codebase
        $this.CompanyID = $Response.CompanyID
        $this.CompanyName = $Response.CompanyName
        $this.IsCloud  =$Response.IsCloud
        $this.SiteUrl  = $Response.SiteUrl
        $this.VersionCode = $Response.VersionCode
        $this.VersionNumber = $Response.VersionNumber
    }

    [void]CreateAPIRequestURL() {
        $this.APIRequestURL = "http://" + $this.ConnectwiseSite + "/" + $this.codebase + "apis/3.0/"
    }

    [void]StoreAPIKeys([string] $public, [string] $private) {
        $this.PrivateKey = $private
        $this.PublicKey = $public
        $username = $this.LoginCompanyId + $public
        $credpair = "$($username):$($private)"
        $encodedCredentials =  [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}+{1}:{2}" -f $this.LoginCompanyId, $this.PublicKey, $this.PrivateKey)));
        $this.AuthHeader = @{ Authorization = "Basic $encodedCredentials"; clientid  = $this.ClientID}
        $this.JSONHeader = @{ Authorization = "Basic $encodedCredentials"; clientid  = $this.ClientID; "Content-Type" = "application/json"; }
        write-host "Basic $encodedCredentials"
    }
        
    [Object[]]DoRESTGetAction([string] $request) {
        $URI = "$($this.APIRequestURL)$request"
        $result = Invoke-RestMethod -Method Get -Uri $URI  -Headers $this.AuthHeader -UseBasicParsing -ContentType "application/json"
        return $result;
    }

    [Object[]]DoRESTPatchAction([string] $request, [string] $action) {
        #$action = ConvertTo-Json -Compress -InputObject $action -depth 100 |Out-String
        #$action ="[$action]"
        #write-host $action
        $result = Invoke-RestMethod -Method Patch -Uri "$($this.APIRequestURL)$request" -Headers $this.AuthHeader -ContentType "application/json" -UseBasicParsing -Body $action
        return $result;
    }
    [Object[]]DoRESTPOSTAction([string] $request, [string] $JSON) {
        $result = Invoke-RestMethod -Method Post -Uri "$($this.APIRequestURL)$request" -Headers $this.AuthHeader -ContentType "application/json" -UseBasicParsing -Body $JSON
        return $result;
    }

    [Object[]]SetTicketStatus([string] $ticket, [string] $newStatus) {
        $patchOperation = [PSCustomObject] @{
            op    = [string]"replace";
            path  = [string]"status/id";
            value = $newStatus;
        }
        return $this.DoRESTPatchAction("service/tickets/"+$ticket,$patchOperation)
    }

    [Object[]]CreateTicket([string] $summary, [string] $description, [uint32] $companyID, [string] $owner, [uint32] $boardID, [uint32] $typeID, [uint32] $subTypeID, [uint32] $statusId, [string] $datetime, [double] $budget) {
            ##"2019-09-13T17:59:51Z",
            $ticketJSON = 
                "{
                    ""id"": 0,
                    ""summary"": ""$($summary)"",
                    ""recordType"": ""ServiceTicket"",
                    ""board"": { ""id"": ""$($boardID)"" },
                    ""status"": { ""id"": $($statusID)  },
                    ""company"": { ""id"": $($companyID) },
                    ""type"": { ""id"": $($typeID) },
                    ""subType"": { ""id"": $($subtypeID) },
                    ""owner"": { ""identifier"": ""$($owner)"" },
                    ""requiredDate"": ""$($datetime)"",
                    ""budgetHours"": $($budget)
                }"
            

                #write-host $ticketJSON

        return  $this.DoRESTPOSTAction("service/tickets", $ticketJSON)
    }
    [Object[]]CreateTicket_NoDate([string] $summary, [string] $description, [uint32] $companyID, [string] $owner, [uint32] $boardID, [uint32] $typeID, [uint32] $subTypeID, [uint32] $statusId, [double] $budget) {
            ##"2019-09-13T17:59:51Z",
            $ticketJSON = 
                "{
                    ""id"": 0,
                    ""summary"": ""$($summary)"",
                    ""recordType"": ""ServiceTicket"",
                    ""board"": { ""id"": ""$($boardID)"" },
                    ""status"": { ""id"": $($statusID)  },
                    ""company"": { ""id"": $($companyID) },
                    ""type"": { ""id"": $($typeID) },
                    ""subType"": { ""id"": $($subtypeID) },
                    ""owner"": { ""identifier"": ""$($owner)"" },
                    ""budgetHours"": $($budget)
                }"
            

                #write-host $ticketJSON
               $result = $this.DoRESTPOSTAction("service/tickets", $ticketJSON)

        return  $result
    }

     [Object[]]CreateTicket_([string] $summary, [string] $description, [string] $companyID, [string] $owner, [uint32] $boardID, [uint32] $typeID, [uint32] $subTypeID, [uint32] $statusId, [string] $datetime, [double] $budget) {
            
            $ticketJSON = 
                "{
                    ""id"": 0,
                    ""summary"": ""$($summary)"",
                    ""recordType"": ""ServiceTicket"",
                    ""board"": { ""id"": ""$($boardID)"" },
                    ""status"": { ""id"": $($statusID)  },
                    ""company"": { ""identifier"": ""$($companyID)"" },
                    ""type"": { ""id"": $($typeID) },
                    ""subType"": { ""id"": $($subtypeID) },
                    ""owner"": { ""identifier"": ""$($owner)"" },
                    ""requiredDate"": ""$($datetime)"",
                    ""budgetHours"": $($budget)
                }"
            

                #write-host $ticketJSON

        return  $this.DoRESTPOSTAction("service/tickets", $ticketJSON)
    }

    [Object[]]GetServiceBoards([int] $size) {
        return $this.DoRESTGetAction("service/boards?&pageSize="+ $size.ToString())
    }

    [Object[]]GetServiceBoardTypes([int] $board, [int] $size) {
        return $this.DoRESTGetAction("service/boards/"+ $board.ToString() + "/types?&pageSize="+ $size.ToString())
    }

    [Object[]]GetServiceBoardSubTypes([int] $board, [int] $size) {
        return $this.DoRESTGetAction("service/boards/"+ $board.ToString() + "/subtypes?&pageSize="+ $size.ToString())
    }

    [Object[]]GetServiceBoardStatuses([int] $board, [int] $size) {
        return $this.DoRESTGetAction("service/boards/"+ $board.ToString() + "/statuses?&pageSize="+ $size.ToString())
    }
    [Object[]]GetConfigurationTypes([int] $size) {
        return $this.DoRESTGetAction("company/configurations/types?&pageSize="+ $size.ToString())
    }

    [Object[]]GetTicket([int] $ticket) {
        return $this.DoRESTGetAction("service/tickets/"+ $ticket.ToString())
    }

    [bool]Connect() {
        if ($this.GetCallingComanyInfo() -eq $false) {
            Write-Error "Failed to connect to the server, closing"
            return $false;
        } else {
            write-host "Connected: $($this.ConnectwiseSite)" -ForegroundColor Green
            if ($this.SupportedVersion -eq $this.VersionCode) {
                write-host "API Version Match: $($this.VersionCode)" -ForegroundColor Green
            } else {
                Write-warning "API Version Mismatch"
                Write-warning "API Version (Supported): $($this.SupportedVersion)"
                write-warning "API Version (Server): $($this.VersionCode)"
            }
        }
        return $true
    }


 #   authorization: Basic ZXF1aWxpYnJpdW1NTERCSEJ2aDVMTkx5dnVLOlFNY1ZkQW9qTjhwNkVBOUo=
}

$Server = [CWServer]::new("equilibrium", "eqwf.equilibriuminc.com", "MLDBHBvh5LNLyvuK", "QMcVdAojN8p6EA9J")
$server.connect()
$server.GetConfigurationTypes(150)| ft -Property id, name, inactiveFlag
$server.GetConfigurationTypes(150) | Select-Object -Property id, name, inactiveFlag | Export-csv -Path C:\users\mdeliberto\desktop\cwm-configtypes.csv


  $action1="{
    ""op"": ""replace"",
    ""path"": ""type"",
    ""value"": 
    	{
          ""id"": ""111""
        }
  }"

#$ii = 19350
#$gettarget = "configurations/types?&pageSize=150"
#$target = "company/configurations/"+  $ii  +"/changetype"
#$server.AuthHeader


#$server.DoRESTGETaction($gettarget)
#$server.DoRESTPatchaction($target, $action1)


#$q="conditions=board/id=71"


#$result = Invoke-RestMethod -Method Get -Uri "$($Server.APIRequestURL)service/tickets/1413359" -Headers $Server.AuthHeader -UseBasicParsing

#$result = Invoke-RestMethod -Method Get -Uri "$($Server.APIRequestURL)service/tickets?$q" -Headers $Server.AuthHeader -UseBasicParsing

#$Server.PrintAllServiceBoards()

#$server.GetServiceBoards(100) | ft -Property id, name

#$server.GetServiceBoardTypes(71, 100) | ft
#$server.GetServiceBoardSubTypes(71, 100) | ft
#$server.GetServiceBoardStatuses(71, 100) | ft

#$server.getTicket(1413359) | fl -property id, status
#$server.SetTicketStatus("1413359", "1025")
#$server.getTicket(1413359)  | fl -property id, status

#$server.CreateTicket("I made this with powershell as well", "This is where the description  will go", `
#                   30113, "Cjackson", 71, 421, 568, 1022, "2019-09-14T17:59:51Z", .25)

#Invoke-RestMethod -Method Patch -Uri "$($this.APIRequestURL)service/tickets/1413359" -Headers $this.AuthHeader -UseBasicParsing

#$result = Invoke-RestMethod -Method Get -Uri "$($Server.APIRequestURL)service/boards?&pageSize=100" -Headers $Server.AuthHeader -UseBasicParsing
 #       $result.GetType()
  #      
   #     $result | ft -property  id,name
#$LoginCompanyId = "equilibrium"
#$ConnectwiseSite = "eqwf.equilibriuminc.com"
#$URL = "https://" + $ConnectWiseSite + "/login/companyinfo/" + $LoginCompanyId


