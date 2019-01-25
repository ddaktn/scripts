[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,
                    Position=0)]
        [ValidateSet("docker-app","docker-app-itg","docker-app-lab","docker-app-lab2")]
        [string]$loadBalancer,

        [Parameter(Mandatory=$false,
                    Position=1)]
        [string]$domainController = "omahcis04",

        [Parameter(Mandatory=$false,
                    Position=2)]
        [string]$dnsZone = "mutualofomaha.com",

        [Parameter(Mandatory=$false,
                    Position=3)]
        [switch]$revert = $false
    )

FUNCTION Set-DnsCnameRecord {
    BEGIN{
        [string]$file = "DockerCnameRecord-SET-$loadBalancer-" + (Get-Date -Format yyyy-MM-ddTHH-mm-ss-ff) + ".csv"
    }
    PROCESS{
        Invoke-Command -ComputerName $dc -ScriptBlock {
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
            Clear-Content $outFile -ErrorAction SilentlyContinue
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
            $aliasRecords = Get-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -RRType CName | Where-Object {$_.RecordData.HostNameAlias -eq "$lbName."}            
            foreach($record in $aliasRecords) {
                if(($record.HostName).EndsWith("-itg")) {
                    $new = $old = $record
                    $new.RecordData.HostNameAlias = "$itgLbName."
                    TRY {
                        Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                        $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",Success" 
                        Add-Content -Value $info -Path $outFile
                    }
                    CATCH {
                        $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",ERROR" 
                        Add-Content -Value $info -Path $outFile
                    }                   
                } elseif(($record.HostName).EndsWith("-cat")) {
                    $new = $old = $record
                    $new.RecordData.HostNameAlias = "$catLbName."
                    TRY {
                        Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                        $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",Success" 
                        Add-Content -Value $info -Path $outFile
                    }
                    CATCH {
                        $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",ERROR" 
                        Add-Content -Value $info -Path $outFile
                    }
                }
            }
            Copy-Item -Path $outFile -Destination "\\omahcts137\d$\DnsAliasModifyScriptOutput"            
        }
    }
    END{
        $path = "D:\DnsAliasModifyScriptOutput\$file"        
        if(Test-Path $path) {
            Write-Host "The output file $file was successfully moved to the 'D:\DnsAliasModifyScriptOutput' folder on OMAHCTS137."
        } else {
            Write-Host "The output file was not successfully moved to OMAHCTS137. It should still be in the TEMP folder on OMAHCIS04."
        }
    }
}

FUNCTION Undo-DnsCnameRecord {
    BEGIN{
        [string]$file = "DockerCnameRecord-REVERT-$loadBalancer-" + (Get-Date -Format yyyy-MM-ddTHH-mm-ss-ff) + ".csv"
    }
    PROCESS{
        Invoke-Command -ComputerName $dc -ScriptBlock {
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
            Clear-Content $outFile -ErrorAction SilentlyContinue
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
                $itgLbName = $catLbName = $lbName
                $prefix = ""
            }
            $aliasRecords = Get-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -RRType CName |
                    Where-Object {($_.RecordData.HostNameAlias -eq "$lbName$prefix-itg.") -or ($_.RecordData.HostNameAlias -eq "$lbName$prefix-cat.")}
            foreach($record in $aliasRecords) {
                $new = $old = $record
                $new.RecordData.HostNameAlias = "$oldLbName."
                TRY {
                    Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                    $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",Success" 
                    Add-Content -Value $info -Path $outFile
                }
                CATCH {
                    $info = $record.HostName + "," + $old.RecordData.HostNameAlias + "," + $new.RecordData.HostNameAlias + ",ERROR" 
                    Add-Content -Value $info -Path $outFile
                }
            }
            Copy-Item -Path $outFile -Destination "\\omahcts137\d$\DnsAliasModifyScriptOutput"
        }
    }
    END{
        $path = "D:\DnsAliasModifyScriptOutput\$file"        
        if(Test-Path $path) {
            Write-Host "The output file $file was successfully moved to the 'D:\DnsAliasModifyScriptOutput' folder on OMAHCTS137."
        } else {
            Write-Host "The output file was not successfully moved to OMAHCTS137. It should still be in the TEMP folder on OMAHCIS04."
        }
    }
}

if($revert) {
    Undo-DnsCnameRecord $loadBalancer
} else {
    Set-DnsCnameRecord $loadBalancer
}