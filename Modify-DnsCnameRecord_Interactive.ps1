<#
    Interactive DNS Cname modification script for Docker Service Clusters
#>

Clear-Host
Write-Host "`n`nDocker DNS Cname Alias Modification Script for Service Clusters`n" -ForegroundColor Yellow
Write-Host "1 -- docker-app" -ForegroundColor Yellow
Write-Host "2 -- docker-app-itg" -ForegroundColor Yellow
Write-Host "3 -- docker-app-lab" -ForegroundColor Yellow
Write-Host "4 -- docker-app-lab2" -ForegroundColor Yellow
Write-Host "`nWhich Docker load balancer is this for: " -ForegroundColor Yellow -NoNewline

[string]$loadBalancer = Read-Host
if(($loadBalancer -ne "1") -and ($loadBalancer -ne "2") -and ($loadBalancer -ne "3") -and ($loadBalancer -ne "4")) {
    Write-Host "Invalid entry. The script is now exiting." -ForegroundColor Red
    break
}

switch($loadBalancer) {
    "1" {$loadBalancer = "docker-app";break}
    "2" {$loadBalancer = "docker-app-itg";break}
    "3" {$loadBalancer = "docker-app-lab";break}
    "4" {$loadBalancer = "docker-app-lab2";break}
}
Clear-Host

Write-Host "`n`nYou've selected the '$loadBalancer' load balancer.`n" -ForegroundColor Yellow
Write-Host "Do you wish to SET the Cname records for Service Clusters; or do you wish to REVERT back to it's state before service clusters?`n" -ForegroundColor Yellow
Write-Host "1 -- SET records for Service Clusters" -ForegroundColor Yellow
Write-Host "2 -- REVERT to previous state before Service Clusters" -ForegroundColor Yellow
Write-Host "`nPlease choose an action: " -ForegroundColor Yellow -NoNewline

[string]$revert = Read-Host
if(($revert -ne "1") -and ($revert -ne "2")) {
    Write-Host "Invalid entry. The script is now exiting." -ForegroundColor Red
    break
}

switch($revert) {
    "1" {[bool]$revert = $false;break}
    "2" {[bool]$revert = $true;break}
}

FUNCTION Set-DnsCnameRecord {
    BEGIN {
        [string]$file = "DockerCnameRecord-SET-$loadBalancer-" + (Get-Date -Format yyyy-MM-ddTHH-mm-ss-ff) + ".csv"
        [string]$domainController = "omahcis04"
        [string]$dnsZone = "mutualofomaha.com"
    }
    PROCESS {
        Invoke-Command -ComputerName $domainController -ScriptBlock {
            PARAM(
                $outFile = "C:\TEMP\$using:file",
                $header = "HostName,OldAlias,NewAlias,ChangeStatus",
                $dc = $using:domainController,
                $lbName = $using:loadBalancer,
                $zone = $using:dnsZone,
                $itgLbName,
                $catLbName,
                $aliasRecords
            )
            Add-Content -Value $header -Path $outFile
            if($lbName -eq "docker-app") {
                $itgLbName = "$lbName-prod-itg"
                $catLbName = "$lbName-prod-cat"
            } elseif($lbName -eq "docker-app-itg") {
                $itgLbName = "$lbName-itg"
                $catLbName = "$lbName-cat"
            } elseif($lbName -eq "docker-app-lab") {
                $itgLbName = "$lbName-itg"
                $catLbName = "$lbName-cat"
            } else {
                $itgLbName = "$lbName-itg"
                $catLbName = "$lbName-cat"
            }
            $aliasRecords = Get-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -RRType CName | Where-Object {$_.RecordData.HostNameAlias -eq "$lbName.$zone."}            
            foreach($record in $aliasRecords) {
                if(($record.HostName).EndsWith("-itg")) {
                    $old = $record
                    $new = $record.Clone() 
                    $new.RecordData.HostNameAlias = "$itgLbName.$zone."
                    TRY {
                        Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                        $info = "{0},{1},{2},Success" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias
                        $info 
                        Add-Content -Value $info -Path $outFile
                    }
                    CATCH {
                        $info = "{0},{1},{2},ERROR" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias 
                        $info
                        Add-Content -Value $info -Path $outFile
                    }                   
                } elseif(($record.HostName).EndsWith("-cat")) { 
                    $old = $record
                    $new = $record.Clone()
                    $new.RecordData.HostNameAlias = "$catLbName.$zone."    
                    TRY {
                        Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                        $info = "{0},{1},{2},Success" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias
                        $info
                        Add-Content -Value $info -Path $outFile
                    }
                    CATCH {
                        $info = "{0},{1},{2},ERROR" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias
                        $info 
                        Add-Content -Value $info -Path $outFile
                    }
                }
            }
            Copy-Item -Path $outFile -Destination "\\omahcts137\d$\DnsAliasModifyScriptOutput"            
        }
    }
    END {
        $path = "D:\DnsAliasModifyScriptOutput\$file"        
        if(Test-Path $path) {
            Write-Host "The output file $file was successfully moved to the 'D:\DnsAliasModifyScriptOutput' folder on OMAHCTS137."
        } else {
            Write-Host "The output file was not successfully moved to OMAHCTS137. It should still be in the TEMP folder on $domainController."
        }
    }
}

FUNCTION Undo-DnsCnameRecord {
    BEGIN {
        [string]$file = "DockerCnameRecord-REVERT-$loadBalancer-" + (Get-Date -Format yyyy-MM-ddTHH-mm-ss-ff) + ".csv"
        [string]$domainController = "omahcis04"
        [string]$dnsZone = "mutualofomaha.com"
    }
    PROCESS {
        Invoke-Command -ComputerName $domainController -ScriptBlock {
            PARAM(
                $outFile = "C:\TEMP\$using:file",
                $header = "HostName,OldAlias,NewAlias,ChangeStatus",
                $dc = $using:domainController,
                $lbName = $using:loadBalancer,
                $zone = $using:dnsZone,
                $itgLbName,
                $catLbName,
                $aliasRecords
            )
            Add-Content -Value $header -Path $outFile
            if($lbName -eq "docker-app") {
                $oldLbName = $lbName
                $prefix = "-prod"                
            } elseif($lbName -eq "docker-app-itg") {
                $oldLbName = $lbName
                $prefix = ""
            } elseif($lbName -eq "docker-app-lab") {
                $oldLbName = $lbName
                $prefix = ""
            } else {
                $oldLbName = $lbName
                $prefix = ""
            }
            $aliasRecords = Get-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -RRType CName |
                    Where-Object {($_.RecordData.HostNameAlias -eq "$lbName$prefix-itg.$zone.") -or ($_.RecordData.HostNameAlias -eq "$lbName$prefix-cat.$zone.")}
            foreach($record in $aliasRecords) {
                if(($record.HostName).EndsWith("-itg") -or ($record.HostName).EndsWith("-cat")) {
                    $old = $record
                    $new = $record.Clone()
                    $new.RecordData.HostNameAlias = "$oldLbName.$zone."               
                    TRY {
                        Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                        $info = "{0},{1},{2},Success" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias
                        $info 
                        Add-Content -Value $info -Path $outFile
                    }
                    CATCH {
                        $info = "{0},{1},{2},ERROR" -f $record.HostName,$old.RecordData.HostNameAlias,$new.RecordData.HostNameAlias
                        $info 
                        Add-Content -Value $info -Path $outFile
                    }
                }   
            }
            Copy-Item -Path $outFile -Destination "\\omahcts137\d$\DnsAliasModifyScriptOutput"
        }
    }
    END {
        $path = "D:\DnsAliasModifyScriptOutput\$file"        
        if(Test-Path $path) {
            Write-Host "The output file $file was successfully moved to the 'D:\DnsAliasModifyScriptOutput' folder on OMAHCTS137."
        } else {
            Write-Host "The output file was not successfully moved to OMAHCTS137. It should still be in the TEMP folder on $domainController."
        }
    }
}

if($revert) {
    Undo-DnsCnameRecord $loadBalancer
} else {
    Set-DnsCnameRecord $loadBalancer
}