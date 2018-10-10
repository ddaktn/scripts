<#
    Script to check if Windows Servers are up
    Doug Nelson
    10/9/2018
#>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                    Position=0)]
        [string]$list = "C:\Temp\CloudWindowsList.csv",

        [Parameter(Mandatory=$false,
                    Position=1)]
        [string]$log = "C:\Temp\CloudWindowsList-ERROR.csv"
    )
FUNCTION serverCheck {
    BEGIN{
        #Get-Module vmware* -ListAvailable | Import-Module
        #Connect-VIServer "omahcsm07.corp.mutualofomaha.com"
        $servers = Get-Content $list 
    }
    PROCESS{
        foreach ($server in $servers) {
            if(Test-Connection -Count 1 $server) {
                Invoke-Command -ComputerName $server -ScriptBlock{
                    $env:COMPUTERNAME
                } -ErrorVariable errorText
                if($errorText){
                    "$server, Error: PING succeeded, but couldn't connect" | Add-content $log
                }
            } else {
                "$server, Error: PING failed" | Add-content $log
            }
        }
    }
    END{}
}
serverCheck $list $log 