#For remote computer
#$RemoteComputer = ""
#Invoke-Command -ComputerName $RemoteComputer -scriptblock {get-eventlog -log system -newest 200000 | where {$_.eventID -eq 1074} | format-table machinename,source,username,timegenerated -AutoSize}

#For localcomputer
#get-eventlog -log system -newest 200000 | where {$_.eventID -eq 1074} | format-table machinename,source,username,timegenerated -AutoSize

