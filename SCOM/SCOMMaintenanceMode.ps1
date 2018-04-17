###Put Server in Maintenance Mode for specified period of minutes

##Import SCOM module and connect to SCOM server
Import-Module OperationsManager
New-SCOMManagementGroupConnection -ComputerName scomgt01prd

##Specify the server and the amount of minutes to put machine into maintenance
$Instance = Get-SCOMClassInstance "xxxxxx01prd.bcbsneprd.com"
$Time = ((Get-Date).AddMinutes(60))

Start-SCOMMaintenanceMode -Instance $Instance -EndTime $Time -Reason "PlannedOther"

##Add minutes to a server already in maintenance mode
$Instance = Get-SCOMClassInstance -Name "xxxxxx01prd.bcbsneprd.com"
$MMEntry = Get-SCOMMaintenanceMode -Instance $Instance
$NewEndTime = (Get-Date).addMinutes(5)
Set-SCOMMaintenanceMode -MaintenanceModeEntry $MMEntry -EndTime $NewEndTime -Comment "Adding 5 minutes to the end time."
