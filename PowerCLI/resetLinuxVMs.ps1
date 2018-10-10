<#
    Reset all Linux VMs
    Doug Nelson
    10/9/2018
#>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                    Position=0)]
        [string]$list = "C:\Temp\LinuxList.csv",

        [Parameter(Mandatory=$false,
                    Position=1)]
        [string]$log = "C:\Temp\LinuxList-ERROR.csv"
    )
FUNCTION Reset-LinuxVM {
    BEGIN{
        Get-Module vmware* -ListAvailable | Import-Module
        Connect-VIServer "omahcsm07.corp.mutualofomaha.com"
        $servers = Get-Content $list
    }
    PROCESS{
        foreach ($server in $servers) {
            TRY{
                Restart-VM -VM $server -Confirm:$false               
            } 
            CATCH{
                "$server, could not be restarted" | append-log $log 
            }
        }
    }
    END{}
}
Reset-LinuxVM $list $log 