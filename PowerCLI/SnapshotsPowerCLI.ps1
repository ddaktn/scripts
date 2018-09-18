### Import PowerCLI module ###
Get-Module -ListAvailable -Name VM* | Import-Module

#Connect to ITG vCenter
Connect-VIServer omahcsm81.corp.mutualofomaha.com
#Connect to Prod vCenter
Connect-VIServer omahcsm07.corp.mutualofomaha.com

#### Create variable for server name ###
Write-Host "Enter server name that you snapshotted: " -NoNewline -ForegroundColor Yellow
$snapShot = Read-Host
#Take a snapshot of a server with a name (i made the name the same as the server for simplicity) and description (creation date)
New-Snapshot -vm $snapShot -Name "$snapShot" -Memory:$true -Quiesce:$true -Description "Created by Doug Nelson $(get-date)"


#Get all snapshots in the environment
Get-VM | Get-Snapshot
#Get snapshot for specific machine
get-snapshot -vm (Read-Host "Enter name of VM to check for snapshots: ")
#Remove snapshot for specific machine
get-snapshot -vm (Read-Host "Enter name of VM to REMOVE snapshots: ") | Remove-Snapshot


#### Revert to snapshot ###
Write-Host "Enter server name to REVERT snapshot: " -NoNewline -ForegroundColor Yellow
$revertSnapshot = Read-Host
set-vm -VM $revertSnapshot -Snapshot (get-vm $revertSnapshot | Get-Snapshot)
