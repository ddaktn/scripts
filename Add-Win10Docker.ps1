<#
    Script to add Docker executables to Windows 10 Machine
        FUNCTION Install-DockerReqs:
            - Enable hardware virtualization in BIOS/VM settings
            - Install/Enable Hyper-V
        FUNCTION Install-DockerBits
            - Install Docker executable
    Doug Nelson
    04/20/18
#>

function Install-DockerReqs{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$vmName,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$adminAccount,

        [Parameter(Mandatory=$true,
                   Position=2)]
        [string]$adminPassword,

        [Parameter(Mandatory=$false,
                   Position=3)]
        [ValidateSet("Prod","ITG")]
        [string]$environment = "Prod"
    )
    BEGIN{
        if($environment -eq "Prod"){
            $vCenter = 'omahcsm43.corp.mutualofomaha.com'
        } elseif($environment -eq "ITG"){
            $vCenter = 'omahcsm81.corp.mutualofomaha.com'
        }
        Get-Module  VMware.VimAutomation.Core -ListAvailable | Import-Module
        Connect-VIServer -Server $vCenter -User $adminAccount -Password $adminPassword
    }
    PROCESS{
        #enable hardware virtualization
        $vm = Get-VM -Name $vmName
        Get-VM $vm | Stop-VM -Confirm:$false
        Start-Sleep -Seconds 30

        $spec = New-Object VMware.Vim.VirtualMachineConfigSpec
        $spec.nestedHVEnabled = $true
        $vm.ExtensionData.ReconfigVM($spec)
        Start-Sleep -Seconds 10

        Get-VM $vm | Start-VM
        Start-Sleep -Seconds 180

        #install/enable hyper-V
        WHILE($true){
            if(Test-Connection -ComputerName $vmName -Quiet) {
                "Invoking to $vmName"
                Invoke-Command -ComputerName $vmName -ScriptBlock{
                    $using:vmName
                    $state = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V
                    if($state.State -eq 'Enabled'){
                        "Hyper-V is already installed on $using:vmName."
                    } else {
                        TRY{
                            Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart
                            "INSTALLING STATUS: Installing the Hyper-V feature."
                        }
                        CATCH{
                            "INSTALLING STATUS: The Hyper-V feature is not installing. It was either already installed, or something went wrong. Check completion status."
                        }
                        FINALLY{
                            if($state.State -eq 'Enabled'){
                                "COMPLETION STATUS: The Hyper-V feature is successfully installed on $using:vmName. Now rebooting..."
                                Restart-Computer
                            } else {
                                "COMPLETION STATUS: The Hyper-V feature is NOT installed. Something did not work."
                            }
                        }
                    }
                }
                break;
            } else {
                Start-Sleep -Seconds 10
            }
        }
        Start-Sleep -Seconds 300
    }
    END{
        Disconnect-VIServer -Server $vCenter -Force -Confirm:$false
    }
}

function Install-DockerBits{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true,
                   Position=0)]
        [string]$vmName,

        [Parameter(Mandatory=$true,
                   Position=1)]
        [string]$dockerUser,

        [Parameter(Mandatory=$false,
                   Position=2)]
        [ValidateSet("Linux","Windows")]
        [string]$containerType = "Linux"
    )
    BEGIN{}
    PROCESS{
        #install docker
        WHILE($true){
            if(Test-Connection -ComputerName $vmName -Quiet){
                if($containerType = "Linux"){
                    Invoke-Command -ComputerName $vmName -ScriptBlock{
                        $using:vmName
                        $DockerInstaller = Join-Path $Env:Temp InstallDocker.msi
                        TRY{
                            Invoke-WebRequest https://download.docker.com/win/stable/InstallDocker.msi -OutFile $DockerInstaller
                            msiexec -i $DockerInstaller -qn
                            $installSuccess = 1
                            Start-Sleep -seconds 120
                        }
                        CATCH{
                            "Docker did not install..."
                        }
                        FINALLY{
                            if($installSuccess -eq 1){
                                "Docker has been installed successfully!"
                            } else {
                                "Something has gone wrong with the Docker install! Back to the drawing board!"
                            }
                        }
                    }
                } else {
                    Invoke-Command -ComputerName $vmName -ScriptBlock{
                        Invoke-WebRequest "https://master.dockerproject.org/windows/amd64/dockerd.exe" -OutFile "${Env:ProgramFiles}\docker\dockerd.exe"
                        & "${Env:ProgramFiles}\docker\dockerd.exe" -H npipe:////./pipe/win_engine --service-name=com.docker.windows --register-service
                    }
                }
                break;
            } else {
                "The server $vmName is not responding to ping. The docker install script will now exit."
                break;
            } 
        }
        #add VDI user to local docker group
        Start-Sleep -Seconds 180
        Invoke-Command -ComputerName $vmName -ScriptBlock {
            $using:dockerUser
            $dockerGroup = "docker-users"
            $computer = $env:COMPUTERNAME
            $domain = $env:USERDOMAIN
            $groupCheck = Get-CimInstance Win32_Group -Filter "Name=$dockerGroup"
            $query = "Associators of {Win32_Group.Domain='$Computer',Name='$DockerGroup'} where Role=GroupComponent"
            if($groupCheck){
                if(Get-CimInstance -Query $query -ComputerName $computer | ForEach-Object {$_.Name -eq $using:dockerUser}){
                    "The user $using:dockerUser is already in the local $dockerGroup group."
                } else {
                    TRY{
                        ([ADSI]"WinNT://$computer/$dockerGroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$domain/$using:dockerUser").path)
                        "Added $using:dockerUser to the newly created local $dockerGroup group."
                    }
                    CATCH{
                        "The $dockerGroup local group DOES exist, but did NOT successfully add $using:dockerUser to it!!!"
                    }
                }
            } else {
                "The docker group $dockerGroup was NOT created! Something went wrong with the install!!!"
            }
        }
    }
    END{}
}