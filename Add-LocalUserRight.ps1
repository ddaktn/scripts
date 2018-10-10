<##############################################################################
#   Add local user right script
#   Doug Nelson
#   10/10/2018
##############################################################################>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                    Position=0)]
        [string[]]$accounts = "svcboe42np",

        [Parameter(Mandatory=$false,
                    Position=1)]
        [string[]]$servers = ("WN1406","WN1408","WN1419","WN1420"),        

        [Parameter(Mandatory=$false,
                    Position=2)]
        [string]$right = "SeTcbPrivilege"        
    )

FUNCTION Add-LocalUserRight {
    BEGIN{}
    PROCESS{
        foreach($server in $servers) {
            if(Test-Connection -Count 1 $server) {                
                Invoke-Command -ComputerName $server -ScriptBlock {                    
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
                    "$server, Error: PING succeeded, but couldn't connect -- $(get-date)"
                }              
            } else {
                "$server, Error: PING failed -- $(get-date)"             
            }
        }
    }
    END{}
}
Add-LocalUserRight $accounts $servers $right 