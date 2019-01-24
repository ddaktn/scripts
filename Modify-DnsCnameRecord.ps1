[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,
                    Position=0)]
        [ValidateSet("docker-app","docker-app-itg","docker-app-lab","docker-app-lab2")]
        [string]$loadBalancer,

        [Parameter(Mandatory=$false,
                    Position=1)]
        [switch]$revert = $false,

        [Parameter(Mandatory=$false,
                    Position=2)]
        [string]$domainController = "omahcis04"
    )

FUNCTION Set-DnsCnameRecord {
    BEGIN{}
    PROCESS{
        Invoke-Command -ComputerName $dc -ScriptBlock {
            PARAM(
                $outFile = "C:\TEMP\DockerCnameRecordChange.csv",
                $dc = $using:domainController,
                $lbName = $using:loadBalancer,
                $zone = "mutualofomaha.com",
                $itgLbName,
                $catLbName,
                $aliasRecords
            )
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
                    Set-DnsServerResourceRecord -ComputerName $dc -ZoneName $zone -NewInputObject $new -OldInputObject $old
                }
            }            
        }
    }
    END{}
}

FUNCTION Undo-DnsCnameRecord {
    BEGIN{}
    PROCESS{}
    END{}
}

if($revert) {
    Undo-DnsCnameRecord
} else {
    Set-DnsCnameRecord
}