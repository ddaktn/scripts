<##############################################################################
#   Add "Logon As A Service" user right script
#   Doug Nelson
#   9/27/2018
##############################################################################>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                    Position=0)]
        [string[]]$accounts = ("svcctmagp","svcctmags"),

        [Parameter(Mandatory=$false,
                    Position=1)]
        [string]$list = "\\ntmaster\code\scripts\NTMServers-TEST.csv",

        [Parameter(Mandatory=$false,
                    Position=2)]
        [string]$log = "\\ntmaster\code\scripts\NTMServers-TEST-ERROR.csv",

        [Parameter(Mandatory=$false,
                    Position=3)]
        [string[]]$localGroups = ("APPBTCH","SysMgt"),

        [Parameter(Mandatory=$false,
                    Position=4)]
        [string]$right = "SeServiceLogonRight"        
    )

FUNCTION Add-LogonAsService {
    BEGIN{
        [string[]]$servers = Get-Content $list 
        [DateTime]$startTime = Get-Date       
    }
    PROCESS{
        foreach($server in $servers) {
            if(Test-Connection -Count 1 $server) {                
                Invoke-Command -ComputerName $server -ScriptBlock {
                    $comp = $env:COMPUTERNAME
                    $cn = [ADSI]"WinNT://$comp"
                    $domain = $env:USERDOMAIN
                    $localLog = "C:\SysMgt-LogonAsService-LOG.txt"
                    foreach($localGroup in $using:localGroups){
                        $group = $cn.Create("Group", $localGroup)
                        try{
                            $group.setinfo()
                            "The group $group was successfully created on the local machine. -- $(get-date)" | Add-Content $localLog 
                        } 
                        catch {
                            "The group $group already exists, moving forward with script. -- $(get-date)" | Add-Content $localLog
                        }
                    }                        
                    ForEach($account in $using:accounts){   
                        ForEach($localGroup in $using:localGroups){
                            try{
                                ([ADSI]"WinNT://$comp/$localgroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$domain/$account").path)
                                "The $account was successfully added to the $localGroup group. -- $(get-date)" | Add-Content $localLog
                            } 
                            catch {
                                "The $account account is already in the $localGroup group, moving forward with the script. -- $(get-date)" | Add-Content $localLog
                            }
                        }
                    }
                    ForEach($account in $using:accounts){
                        if([string]::IsNullOrEmpty($account)){
                            Write-Host "no account specified"
                            exit
                        }
                        $sidstr = $null
                        try {
                            $ntprincipal = new-object System.Security.Principal.NTAccount "$account"
                            $sid = $ntprincipal.Translate([System.Security.Principal.SecurityIdentifier])
                            $sidstr = $sid.Value.ToString()
                        } catch {
                            $sidstr = $null
                        }
                        Write-Host "Account: $($account)" -ForegroundColor DarkCyan
                        if([string]::IsNullOrEmpty($sidstr)){
                            Write-Host "Account not found!" -ForegroundColor Red
                            exit -1
                        }
                        Write-Host "SID: $($sidstr)" -ForegroundColor DarkCyan
                        $tmp = [System.IO.Path]::GetTempFileName()
                        Write-Host "Export current Local Security Policy" -ForegroundColor DarkCyan
                        secedit.exe /export /cfg "$($tmp)"
                        $c = Get-Content -Path $tmp
                        $currentSetting = ""
                        foreach($s in $c) {
                            if ($s -like "$using:right" -or $s -like "$using:right*") {
                                $x = $s.split("=",[System.StringSplitOptions]::RemoveEmptyEntries)
                                $currentSetting = $x[1].Trim()
                            }
                        }
                        if( $currentSetting -notlike "*$($sidstr)*" ) {
                            Write-Host "Modify Setting $using:right" -ForegroundColor DarkCyan	
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
$using:right = $($currentSetting)
"@
                            $tmp2 = [System.IO.Path]::GetTempFileName()	
                            Write-Host "Import new settings to Local Security Policy" -ForegroundColor DarkCyan
                            $outfile | Set-Content -Path $tmp2 -Encoding Unicode -Force
                            Push-Location (Split-Path $tmp2)	
                            try {
                                secedit.exe /configure /db "secedit.sdb" /cfg "$($tmp2)" /areas USER_RIGHTS 
                                "The $using:right right was successfully added to $account. -- $(get-date)" | Add-Content $localLog
                            } finally {	
                                Pop-Location
                                Write-Host "The $using:right right was successfully added to $account" -ForegroundColor DarkCyan
                            }
                        } else {
                            Write-Host "$account already has the $using:right right." -ForegroundColor DarkCyan
                            "The $account already has the $using:right right. -- $(get-date)"
                        }    
                    }
                } -ErrorVariable errorText
                if($errorText){
                    "$server, Error: PING succeeded, but couldn't connect -- $(get-date)" | Add-content $log
                }              
            } else {
                "$server, Error: PING failed -- $(get-date)" | Add-content $log             
            }
        }
    }
    END{
        Write-Host "Script started at $startTime."
        Write-Host "Script ended at $(get-date)."
    }
}
Add-LogonAsService $accounts $list $log $localGroups $right 