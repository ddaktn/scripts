#Param($NumberOfDays = 30, [switch]$debug)

#if($debug) { $DebugPreference = " continue" }

#$username = "ntmaster\svcsrvmgt01"
#$passwd = cat d:\util\scripts\securepasswd.txt | convertto-securestring
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $passwd
$currentTime = Get-Date
$startUpID = 6005
$timevariable = get-content d:\UTIL\scripts\time_variable_days.txt

write-host $timevariable


write-output "" > d:\util\scripts\not_contacted.txt
write-output "" > d:\util\scripts\restarted.txt
write-output "" > d:\util\scripts\not_restarted.txt
write-output "" > d:\util\scripts\error.txt
write-output "" > d:\util\scripts\uptime.txt
write-output "" > d:\util\scripts\time_setting.txt

write-output "Servers that have booted within 24 hours" > d:\util\scripts\time_setting.txt


#create multiple servers loop here

foreach ($server in get-content d:\UTIL\scripts\serverlist.txt)
		
		
{		
		$uptime=0
		
		write-host "$server"
				

		$LastBoot = (get-wmiobject win32_operatingsystem -cn $server).lastbootuptime
		#$LastBoot = (get-wmiobject win32_operatingsystem -cn $server -Authentication default -Credential $cred).lastbootuptime
		#write-host $LastBoot

		trap { 'Error received {0}' -f $_.Exception.Message
		write-output "$server" >> d:\util\scripts\error.txt
		write-output "$error" >> d:\util\scripts\error.txt
		write-output "$server" >> d:\util\scripts\not_contacted.txt

		$uptime=0

		continue
		}


		
		$uptime = (get-date) - [system.management.managementdatetimeconverter]::todatetime($LastBoot)
		write-output "" >> d:\util\scripts\uptime.txt
		write-host "days ="$uptime.days"hours ="$uptime.hours
		write-output $server >> d:\util\scripts\uptime.txt
		write-output $uptime.days"days"$uptime.hours"hours" >> d:\util\scripts\uptime.txt
		$uptimeconv=$uptime.days

		
	if (($UpTime.days -lt $timevariable) -and ($uptime -gt 0)) {Write-Output $server >> d:\util\scripts\restarted.txt}
	
	else {Write-output $server >> d:\util\scripts\not_restarted.txt}

	#end loop here
	#cls
	
	}
	
	
	


	$count = 0
	$reader = New-Object IO.StreamReader 'd:\UTIL\scripts\serverlist.txt'
	while ($reader.ReadLine() -ne $null){ $count++ }
	$reader.Close()
	
	write-output ""
	write-output "Total servers checked = $count"
