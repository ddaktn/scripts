### Modify VM Resources on EXISTING VM ###
## David Lesac ##
# 01/08/2018 #

# Import VMware PowerCLI module #
Get-Module -Name VMware* -ListAvailable | Import-Module

# Connect to the vCenter instance #
Connect-VIServer omahcsm81.corp.mutualofomaha.com
Connect-VIServer omahcsm07.corp.mutualofomaha.com

# Enter server name for server you want to modify #
Write-Host "Enter server name to modify resources: " -NoNewline -ForegroundColor Yellow
$servername = Read-Host

# Retrieve server object #
$server = Get-VM -Name $servername
$serverCpu = $server.NumCpu
$serverMem = $server.MemoryGB

# Show user how many CPUs the machine has and ask what number to set to #
Write-Host "Server $servername currently has $serverCpu CPUs; Enter desired CPU count: " -NoNewline -ForegroundColor Yellow
[int]$desiredCpu = Read-Host

# Show user how much memory the machine has and ask what number to set it to #
Write-Host "Server $servername currently has $serverMem GBs; Enter desired Memory in GBs: " -NoNewline -ForegroundColor Yellow
[int]$desiredMem = Read-Host

# PowerOff Machine If PoweredOn #
if($server.PowerState -eq "PoweredOn"){
    $server | Stop-VM
}

# Add CPU and Memory To VM #
$server | Set-VM -MemoryGB $desiredMem -NumCpu $desiredCpu

# PowerOn Machine after adding CPU and Memory #
if($server.PowerState -eq "PoweredOff"){
    $server | Start-VM
}