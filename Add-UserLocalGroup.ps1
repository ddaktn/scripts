<#
    Add user to Local "docker-users" Group
    Doug Nelson
    7/31/2018
#>

FUNCTION Add-LocalDockerUser {
    [CmdletBinding()]
        PARAM(
            [Parameter(Mandatory=$false,
                       Position=0)]
            [string]$user = $env:USERNAME,

            [Parameter(Mandatory=$false,
                       Position=1)]
            [string]$computer = $env:COMPUTERNAME,

            [Parameter(Mandatory=$false,
                       Position=2)]
            [string]$domain = $env:USERDOMAIN,

            [Parameter(Mandatory=$false,
                       Position=3)]
            [string]$group = 'docker-users'
        )
        BEGIN{
            $groupCheck = Get-CimInstance Win32_Group -Filter "Name='$group'"
            $query = "Associators of {Win32_Group.Domain='$computer',Name='$group'} where Role=GroupComponent"
        }
        PROCESS{
            if($groupCheck){
                if(Get-CimInstance -Query $query | ForEach-Object {$_.Name -eq $user}){
                    "The user $user is already in the local $group group."
                } else {
                    TRY{
                        ([ADSI]"WinNT://$computer/$group,group").psbase.Invoke("Add",([ADSI]"WinNT://$domain/$user").path)
                        "Added $user to the local $group group."
                    }
                    CATCH{
                        "The $group local group exists, but did not successfully add $user to it!"
                    }
                }
            } else {
                "The $group local group does not exist!"
            }
        }
        END{}
}
Add-LocalDockerUser