<#
    Script to add a DNS ALIAS record
    Doug Nelson
    06/28/2018 -- v1
#>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$cname
    )
    BEGIN{
        $dnsServer = 'omahcis04.corp.mutualofomaha.com'
        $zone = 'mutualofomaha.com'
        $dnsHost = 'docker-app.mutualofomaha.com'
    }
    PROCESS{
        Invoke-Command -ComputerName $dnsServer -ScriptBlock{
            PARAM(
                $using:cname,
                $using:dnsServer,
                $using:zone,
                $using:dnsHost
            )
            if(Resolve-DnsName -Name $using:cname -Type CNAME -Server $using:dnsServer){
                Write-Host "The CNAME $using:cname already exists; no action taken."
            } else {
                Add-DnsServerResourceRecordCName -Name $using:cname -HostNameAlias $using:dnsHost -ComputerName $using:dnsServer -ZoneName $using:zone -ErrorAction SilentlyContinue
                Write-Host "The CNAME $using:cname record was successfully created."
            }
        }
    }
    END{}