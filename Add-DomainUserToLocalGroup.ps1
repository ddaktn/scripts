<#########################################################################
    -Script to ADD domain account to local groups
    -Doug Nelson
    -9/26/2018
#########################################################################>

FUNCTION Add-DomainUserToLocalGroup {
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true,
                       Position=0)]
            [string[]]$DomainAccounts,

            [Parameter(Mandatory=$true,
                       Position=1)]
            [string[]]$Groups
        )
        BEGIN{
            $Computer = $env:COMPUTERNAME
            $Domain = $env:USERDOMAIN        
        }
        PROCESS{
            ForEach($DomainAccount in $DomainAccounts){   
                ForEach($Group in $Groups){
                    try{
                        ([ADSI]"WinNT://$Computer/$Group,group").psbase.Invoke("Add",([ADSI]"WinNT://$Domain/$DomainAccount").path)
                    } catch {
                        "The account is already in the correct group."
                    }
                }
            }    
        }
        END{}
}

# call for new SVC account(s)
$DomainAccounts = 'svcctmag'
$Groups = 'APPBTCH','SysMgt'
Add-DomainUserToLocalGroup -DomainAccounts $DomainAccounts -Groups $Groups