<##################################################################################################
    NAME: Get-VmHotAddPlug.ps1
    DESCRIPTION: Script to check Hot Add settings on a VM
                 *** Script can be run ad-hoc or scripted ***
    HISTORY:
       3/6/2018 initial draft...................................................................dn
       2/11/2020 modified parameter set.........................................................dn
##################################################################################################>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string]$user,

        [Parameter(Mandatory=$false,
                   Position=1)]
        [string]$password,

        [Parameter(Mandatory=$false,
                   Position=2)]
        [string]$vcenter,

        [Parameter(Mandatory=$false,
                   Position=3)]
        [string[]]$vmNames
    )

BEGIN {

    #Import VMware PowerCLI module
    Get-Module VM* -ListAvailable | Import-Module

    if(($user -ne "") -and ($password -ne "") -and ($vcenter -ne "")) {

        #Check if script is running interactively. It isn't, so connect to vCenter with provided arguments
        Connect-VIServer -Server $vcenter -User $user -Password $password
        $interactive = $false

    } else {

        #Script is running interactive. Prompt for values and connect to vCenter.
        $interactive = $true
        Write-Host "Please enter the FQDN for vCenter you wish to connect to: " -NoNewline -ForegroundColor Yellow
        $vcenter = Read-Host
        Write-Host "You will now be prompted for creds..."
        $creds = Get-Credential
        Connect-VIServer -Server $vcenter -Credential $creds -Confirm -ErrorAction:Ignore ; $RC = $?
        
        #Do conditional check on success of vCenter connection. If fails, exit the script. 
        if($RC -eq $false) {
            Write-Host "Either you entered an invalid vCenter or your credentials are bad... Exiting now" -ForegroundColor Red
            Exit
        }

        #Create variable for the VMs to check. Could be a single vm, multiple vms, or all vms via a wildcard '*'
        Write-Host "What VM(s) you would to check HotAdd/HotPlug status on?" -ForegroundColor Yellow 
        Write-Host "Please enter a single vm name; or multiple vm names separated by commas; or '*' for all: " -NoNewline -ForegroundColor Yellow
        $vmNames = Read-Host        
    }
}  

PROCESS {

    #Get the values for each VM
    $vms = (Get-VM -Name $vmNames | Get-View)
    foreach($vm in $vms) {
        $output = $vm | Select-Object @{N="Name";E={$VM.Name}},
                            @{N="Memory Hot Add Enabled";E={$VM.Config.MemoryHotAddEnabled}},
                            @{N="CPU Hot Add Enabled";E={$VM.Config.CpuHotAddEnabled}},
                            @{N="CPU Hot Add and Remove Enabled";E={$VM.Config.CpuHotRemoveEnabled}}
    }

    #Output results to CSV file if run non-interactive and to grid-view if interactive
    if($interactive -eq $true) {
        $output | Out-GridView
    } else {
        $date = Get-date -Format "MM/dd/yyyy_HH:mm"
        $report = $("VM_HotAdd_Report_$date") + ".csv"
        "test" | Export-Csv -Path $("C:\TEMP\$report") -NoTypeInformation
    }
}

END {
    Disconnect-VIServer -Confirm:$false
}
