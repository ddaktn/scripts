# Powershell Script to move VM's between different vCenter environments
# Doug Nelson
# 01/04/2018
# https://blogs.vmware.com/PowerCLI/2017/01/spotlight-move-vm-cmdlet.html

### WILL NEED TO ENTER THE FOLLOWING:
    # SOURCE VCENTER
    # DESTINATION VCENTER
    # NAME OF VM
    # DESTINATION HOST CLUSTER
    # DESTINATION DATASTORE CLUSTER
    # DESTINATION PORTGROUP
#####################################

## Create a credential object ##

# Create PSCredential object
$Creds = Get-Credential

## Import VMware PowerCLI modules ##

# Import PowerCLI modules #
Get-Module -ListAvailable -Name VM* | Import-Module

## Create Variables ##

# Create a variable for Source vCenter #
Write-Host "Enter FQDN of SOURCE vCenter: " -NoNewline -ForegroundColor Yellow
$source = Read-Host
# Connect to source vCenter #
$sourceVCenter = Connect-VIServer $source -Credential $Creds

# Create a variable for Destination vCenter #
Write-Host "Enter FQDN of DESTINATION vCenter: " -NoNewline -ForegroundColor Yellow
$dest = Read-Host
# Connect to destination vCenter #
$destVCenter = Connect-VIServer $dest -Credential $Creds

# Create variable for VM to move #
Write-Host "Enter name of VM to move: " -NoNewline -ForegroundColor Yellow
$vmname = Read-Host
$vm = Get-VM $vmname -Server $source
# Turn off VM if powered on #
if($vm.PowerState -eq "PoweredOn"){
   $vm | Stop-VM -Confirm:$false
}

# Create variable for destination vCenter cluster #
Write-Host "Enter the DESTINATION HOST CLUSTER to migrate VM to: " -NoNewline -ForegroundColor Yellow
$destCluster = Read-Host
$destinationCluster = Get-Cluster -Name $destCluster -Server $dest | Get-VMHost | Select-Object -First 1

# Create variable for destination datastore #
Write-Host "Enter DESTINATION DATASTORE CLUSTER to migrate VM to: " -NoNewline -ForegroundColor Yellow
$destDatastore = Read-Host
$destinationDatastore = Get-DatastoreCluster -Name $destDatastore -Server $dest | Get-Datastore | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1

# Create variable for VM's network adapter and destination PortGroup #
$networkAdapter = Get-NetworkAdapter -VM $vm -Server $source
Write-Host "Enter DESTINATION PORTGROUP name to migrate VM to: " -NoNewline -ForegroundColor Yellow
$destPortGroup = Read-Host
$destinationPortGroup = Get-VDPortgroup -Name $destPortGroup -Server $dest

## Perform the move ##

Move-VM -VM $vm -Destination $destinationCluster -NetworkAdapter $networkAdapter -PortGroup $destinationPortGroup -Datastore $destinationDatastore