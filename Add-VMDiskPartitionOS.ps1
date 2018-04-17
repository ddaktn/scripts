param(
[string]$servername,
[int] $addGb,
$username,
$password
)
## Modify VM Drive space on Existing 
## David Lesac##
#2-08-18#

### import VMware PowerCLI module 
Get-Module -Name VMware* -ListAvailable | Import-Module

### Connect to the vCenter instance
Connect-VIServer omahcsm81.corp.mutualofomaha.com -User $username -Password $password 
Connect-VIServer omahcsm07.corp.mutualofomaha.com -User $username -Password $password 


### Retrieve server object
$server = Get-VM -Name $servername

### Add new drive
$server | New-HardDisk  -CapacityGB $addGb

#region --> Call an invoke to extend the OS with loop (no reboot required)
Invoke-Command -ComputerName $server -ScriptBlock {        
    Update-HostStorageCache
    $VolumeNumber = (Get-Disk | where {$_.partitionstyle -eq ‘raw’}).Number    
    Get-Disk -Number $VolumeNumber | Initialize-Disk -PartitionStyle GPT     
    New-Partition -DiskNumber $VolumeNumber -UseMaximumSize -AssignDriveLetter | Format-Volume -FileSystem NTFS -Confirm:$false -Force
}
"Guest OS Disk successfully Added and partioned"
#endregion 