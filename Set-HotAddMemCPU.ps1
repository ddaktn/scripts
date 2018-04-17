<#########################################################################
    Script to ENABLE vCPU and Memory HOT ADD
    Doug Nelson
    03/06/2018
    *** Script can be called with parameters or run interactively***
#########################################################################>

PARAM(
    [string]$vm,
    [switch]$reboot,
    [string]$user,
    [string]$password
)

#region -- Import PowerCLI module and connect to vCenter environments
    Get-Module VM* -ListAvailable | Import-Module
    if(($user -ne "") -and ($password -ne "")){
        Connect-VIServer -Server omahcsm81.corp.mutualofomaha.com -User $user -Password $password
        Connect-VIServer -Server omahcsm07.corp.mutualofomaha.com -User $user -Password $password
    } else {
        $creds = Get-Credential
        Connect-VIServer -Server omahcsm81.corp.mutualofomaha.com -Credential $creds
        Connect-VIServer -Server omahcsm07.corp.mutualofomaha.com -Credential $creds
        
    }
#endregion

#region -- Create functions to add hot add features
    Function Enable-MemHotAdd($vm){
        $vmview = Get-vm $vm | Get-View 
        $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec        
        $extra = New-Object VMware.Vim.optionvalue
        $extra.Key="mem.hotadd"
        $extra.Value="true"
        $vmConfigSpec.extraconfig += $extra
        $vmview.ReconfigVM($vmConfigSpec)
    }
    Function Enable-vCpuHotAdd($vm){
        $vmview = Get-vm $vm | Get-View 
        $vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec        
        $extra = New-Object VMware.Vim.optionvalue
        $extra.Key="vcpu.hotadd"
        $extra.Value="true"
        $vmConfigSpec.extraconfig += $extra
        $vmview.ReconfigVM($vmConfigSpec)
    }
#endregion

#region -- Prompt for name if not provided and display status of VM set reboot prompt
    if($vm -eq ""){
        Write-Host "What server do you want to enable vCPU/Memory Hot Add for?" -ForegroundColor Yellow
        $vm = Read-Host
        $rebootPrompt = $TRUE
    }
    Write-Host "Current status of VM" -ForegroundColor Yellow
    Get-VM $vm |
        Get-View |
            Select-Object Name,@{N="CpuHotAddEnabled";E={$_.Config.CpuHotAddEnabled}},@{N="MemoryHotAddEnabled";E={$_.Config.MemoryHotAddEnabled}}
#endregion

#region -- Power off machine if currently on
if($vm.PowerState -eq 'PoweredOn'){
    Write-Host "Powering off VM to change configuration" -ForegroundColor Yellow
    Get-VM $vm | Stop-VM -Confirm:$false 
}
#endregion

#region -- Call functions and add hot add features and display new status of VM
    Write-Host "Changing configuration of VM..." -ForegroundColor Yellow
    Enable-MemHotAdd $vm
    Enable-vCpuHotAdd $vm
    Start-Sleep -Seconds 5
    Write-Host "Updated status of VM" -ForegroundColor Yellow
    Get-VM $vm |
        Get-View |
            Select-Object Name,@{N="CpuHotAddEnabled";E={$_.Config.CpuHotAddEnabled}},@{N="MemoryHotAddEnabled";E={$_.Config.MemoryHotAddEnabled}}
#endregion

#region -- Power on machine
if($vm.PowerState -eq 'PoweredOff'){
    Write-Host "Powering on VM after configuration change"
    Get-VM $vm | Start-VM -Confirm:$false
}
#endregion
