
Write-Host "Server to check file size: " -ForegroundColor Yellow -NoNewline
$computer = Read-Host
Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | 
select @{name="Server";expression={$_.pscomputername}},`
deviceID,`
@{name="Size";expression={[math]::Round($_.Size/1GB,2)}},`
@{name="FreeSpace";expression={[math]::Round($_.FreeSpace/1GB,2)}}




### declaring a value as a whole integer ###
Write-Host "Server to check file size: " -ForegroundColor Yellow -NoNewline
$computer = Read-Host
Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | 
select @{name="Server";expression={$_.pscomputername}},`
deviceID,`
@{name="Size";expression={ $_.Size/1GB -as [int]}},`
@{n='FreeSpace(GB)';e={ $_.FreeSpace/1GB -as [int] }}



### Format with -f number formatting switch ###
Write-Host "Server to check file size: " -ForegroundColor Yellow -NoNewline
$computer = Read-Host
Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | 
select @{name="Server";expression={$_.pscomputername}},`
deviceID,`
@{name="Size";expression={"{0:N2}" -f ($_.Size/1GB)}},`
@{n='FreeSpace(GB)';e={"{0:N2}" -f ($_.FreeSpace/1GB)}} 



### Format with "ToString" ###
Write-Host "Server to check file size: " -ForegroundColor Yellow -NoNewline
$computer = Read-Host
Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | 
select @{name="Server";expression={$_.pscomputername}},`
deviceID,`
#Using the "N2" format
@{name="Size";expression={($_.Size/1GB).ToString("N2")}},`
#Using the "#.##" format
@{n='FreeSpace(GB)';e={($_.FreeSpace/1GB).ToString("#.##")}},`
#Using the "0.00" format
@{n='FreeSpace(GB)';e={($_.FreeSpace/1GB).ToString("0.00")}}