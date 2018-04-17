Param (
[Parameter(Mandatory=$true)]
[string]$Computername=""
)
Get-CimInstance -ClassName Win32_OperatingSystem `
-ComputerName $Computername |
Select-Object -Property Caption,LastBootUpTime |
format-list 
