<#
    Scipt to add Systems Management account rights without GPO
    Doug Nelson
    5/31/2018
#>

FUNCTION Add-LocalGroup {
    [CmdletBinding()]    
        Param(
            [Parameter(Mandatory=$true,
                       Position=0)]
            [string[]]$localGroups
        )    
        BEGIN{
            $comp = $env:COMPUTERNAME
            $cn = [ADSI]"WinNT://$comp"         
        }
        PROCESS{
            foreach($localGroup in $localGroups){
                $group = $cn.Create("Group", $localGroup)
                try{
                    $group.setinfo()
                } catch {
                    "The group already exists."
                }
            }
        }
        END{}
}

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

FUNCTION Add-LocalUserRightAssignment {
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$true,
                       Position=0)]
            [string]$accountToAdd,

            [Parameter(Mandatory=$true,
                       Position=1)]
            [string[]]$rights  
        )
        BEGIN{}
        PROCESS{
            foreach ($right in $rights) {
                if([string]::IsNullOrEmpty($accountToAdd)){
                    Write-Host "no account specified"
                    exit
                }
                $sidstr = $null
                try {
                    $ntprincipal = new-object System.Security.Principal.NTAccount "$accountToAdd"
                    $sid = $ntprincipal.Translate([System.Security.Principal.SecurityIdentifier])
                    $sidstr = $sid.Value.ToString()
                } catch {
                    $sidstr = $null
                }
                Write-Host "Account: $($accountToAdd)" -ForegroundColor DarkCyan
                if([string]::IsNullOrEmpty($sidstr)){
                    Write-Host "Account not found!" -ForegroundColor Red
                    exit -1
                }
                Write-Host "Local Group SID: $($sidstr)" -ForegroundColor DarkCyan
                $tmp = [System.IO.Path]::GetTempFileName()
                Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
                secedit.exe /export /cfg "$($tmp)"
                $c = Get-Content -Path $tmp
                $currentSetting = ""
                foreach($s in $c) {
                    if ($s -like "$right" -or $s -like "$right*") {
                        $x = $s.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
                        $currentSetting = $x[1].Trim()
                    }
                }
                if( $currentSetting -notlike "*$($sidstr)*" ) {
                    Write-Host "Modify Setting $right" -ForegroundColor DarkCyan	
                    if( [string]::IsNullOrEmpty($currentSetting) ) {
                        $currentSetting = "*$($sidstr)"
                    } else {
                        $currentSetting = "*$($sidstr),$($currentSetting)"
                    }	
                    Write-Host "$currentSetting"	
$outfile = @"
[Unicode]
Unicode=yes
[Version]
signature="`$CHICAGO`$"
Revision=1
[Privilege Rights]
$right = $($currentSetting)
"@
                    $tmp2 = [System.IO.Path]::GetTempFileName()	
                    Write-Host "Import new settings to Local Security Policy" -ForegroundColor DarkCyan
                    $outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force
                    Push-Location (Split-Path $tmp2)	
                    try {
                        secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)" /areas USER_RIGHTS 
                    } finally {	
                        Pop-Location
                    }
                } else {
                    Write-Host "NO ACTIONS REQUIRED! Account already in $right" -ForegroundColor DarkCyan
                }
                Write-Host "Done." -ForegroundColor DarkCyan
            }
        }
        END{}
}

### FUNCTION CALLS ###

# call function to create local groups
$localGroups = 'APPBTCH','SQLSVC','SysMgt'
Add-LocalGroup -localGroups $localGroups

# call for pntb003 and ptng001 accounts
$DomainAccounts = 'PNTB003','PTNG001'
$Groups = 'Backup Operators','Power Users'
Add-DomainUserToLocalGroup -DomainAccounts $DomainAccounts -Groups $Groups

# call for SVC and P accounts
$DomainAccounts = 'svcSysMgmt','SVCSMSRVMON','SVCSMSRVMONTWO','PNTB003','PTNG001','svcctmagp','svcctmags'
$Groups = 'APPBTCH','SysMgt'
Add-DomainUserToLocalGroup -DomainAccounts $DomainAccounts -Groups $Groups

# call for SysMgt local group
$accountToAdd = "$env:computername\SysMgt"
#$rights = "SeTcbPrivilege","SeIncreaseQuotaPrivilege","SeInteractiveLogonRight","SeBatchLogonRight","SeServiceLogonRight","SeSystemProfilePrivilege","SeAssignPrimaryTokenPrivilege"
$rights = "SeServiceLogonRight"
Add-LocalUserRightAssignment -accountToAdd $accountToAdd -rights $rights

# call for APPBTCH local group
$accountToAdd = "$env:computername\APPBTCH"
$rights = "SeServiceLogonRight"
Add-LocalUserRightAssignment -accountToAdd $accountToAdd -rights $rights

# call for SVCCTMAGP account
$accountToAdd = "$env:USERDOMAIN\svcctmagp"
$rights = "SeServiceLogonRight"
Add-LocalUserRightAssignment -accountToAdd $accountToAdd -rights $rights

# call for SVCCTMAGS account
$accountToAdd = "$env:USERDOMAIN\svcctmags"
$rights = "SeServiceLogonRight"
Add-LocalUserRightAssignment -accountToAdd $accountToAdd -rights $rights

 