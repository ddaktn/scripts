###########  Taking User Input ###############
$Server = Read-Host -Prompt 'Input server  name'
$vmname = Read-Host -Prompt 'Input the VM Name'
$initialCpu = Read-Host -Prompt 'Input initial CPU value'
$initialMem = Read-Host -Prompt 'Input initial mem value'
$CpuStep = Read-Host -Prompt 'Input step for cpu , if not required give 0'
$MemStep = Read-Host -Prompt 'Input step for memory,if not required give 0'
$CpuFinal = Read-Host -Prompt 'Input max limit of CPUs'
$MemFinal = Read-Host -Prompt 'Input max limit of Memory'
##########################################################


Connect-VIServer -Server $Server -User username -Password password
$vm = Get-VM -Name $vmname 
if($vm.PowerState -eq 'PoweredOn') {
    Stop-VM -VM $vm -Confirm:$false
}

########## Enable Hot add ##########################
$view = Get-View -VIObject $vm
$vmConfigSpec = New-Object VMware.Vim.VirtualMachineConfigSpec
$vmConfigSpec.CpuHotAddEnabled = 'True'
$vmConfigSpec.MemoryHotAddEnabled = 'True'
$view.ReconfigVM($vmConfigSpec)

 #### Configuring the VM to its initial Configuration#######

$vm | Set-VM -NumCpu $initialCpu -Confirm:$false
$vm | Set-VM -MemoryGB $initialMem -Confirm:$false

############ Start the VM ###################

Start-VM -VM $vm

############# ADD CPU/Memory in steps separately ###########

if ( $CpuStep -ne 0){
    for($valCpu = $initialCpu; $valCpu -le $CpuFinal; $valCpu+=$CpuStep){
        $vm | Set-VM -NumCpu $valCpu -Confirm:$false
        sleep 30  
    }
}

if($MemStep -ne 0) {
    for($valMem = $initialMem; $valMem -le $MemFinal; $valMem+=$MemStep){
        $vm | Set-VM -MemoryGB $valMem -Confirm:$false
        sleep 30
    }
}