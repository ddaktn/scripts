<##################################################################################################
    Script: Fix-DockerWindowsClient
    Description: Restart the Hyper-V and Docker services to resolve Docker client start failures
    Author: Doug Nelson -- doug.nelson@mutualofomaha.com
    Version:
        01/18/2019 Initial Version..............................................................dn

##################################################################################################>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$true,
                    Position=0)]
        [string]$machine
    )

FUNCTION Reset-DockerWindowsClient {
    BEGIN{}
    PROCESS{
        if(Test-Connection -Count 1 -ComputerName $machine) {
            Invoke-Command -ComputerName $machine -ScriptBlock {
                PARAM(
                    [string[]]$services = ("vmcompute", 
                                           "vmms", 
                                           "com.docker.service")
                )
                foreach($service in $services) {
                    if(Get-Service $service) {
                        TRY {
                            if(Get-Service $service | Where-Object {$_.status -eq "Running"}) {
                                Stop-Service $service
                                Start-Sleep -s 5
                            }
                            Start-Service $service
                            Start-Sleep -s 5
                            Write-Host "The $service service successfully restarted."
                        }
                        CATCH {
                            Write-Host "ERROR: The $service service was NOT successfully restarted."
                        }                        
                    } else {
                        Write-Host "ERROR: The $service is not installed. Not all of the appropriate components are loaded for Docker."
                    }
                }
            } -ErrorVariable errorText
            if($errorText) {
                Write-Host "ERROR: $machine is reachable on the network, but could not create a Powershell session to it."
            }
        } else {
            Write-Host "ERROR: Could not reach $machine on the network."
        }
    }
    END{}
}

Reset-DockerWindowsClient $machine