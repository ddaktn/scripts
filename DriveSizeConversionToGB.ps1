
Write-Host "Server to check file size:" -ForegroundColor Magenta
$computer = Read-Host
Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | 
select @{name="Server";expression={$_.pscomputername}},`
deviceID,`
@{name="Size";expression={[math]::Round($_.Size/1GB,2)}},`
@{name="FreeSpace";expression={[math]::Round($_.FreeSpace/1GB,2)}}




### declaring a value as a whole integer ###
$size = Get-CimInstance Win32_LogicalDisk -filter 'drivetype=3' -ComputerName $computer | select @{n='FreeSpace(GB)';e={ $_.FreeSpace/1GB -as [int] }}