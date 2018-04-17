
$Computernames=Get-Content '\\omahcsm04\d$\util\scripts\serverlist.txt'

Foreach ($Computername in $Computernames) {
Get-CimInstance -ClassName Win32_OperatingSystem `
-ComputerName $Computername |
Select-Object -Property PSComputerName,LastBootUpTime,Caption |
format-list
}