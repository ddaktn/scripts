$collection=$args
$Key = (3,4,2,3,56,34,254,222,1,1,2,23,42,54,33,233,1,34,2,7,6,5,35,43)
#$username = "ntmaster\svcsrvmgt01"
#$passwd = cat d:\util\scripts\securepasswd.txt | convertto-securestring
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $passwd
$timevariable = get-content d:\UTIL\scripts\time_variable_days.txt
#write-host "$collection"

write-output "" > d:\util\scripts\serverlist.txt
write-output "" > d:\util\scripts\serverlist1.txt

d:\UTIL\scripts\getcollections.ps1 "$collection" > d:\UTIL\scripts\serverlist.txt

##### Cleanse the SCCM list #####

get-content d:\UTIL\scripts\serverlist.txt | select -Skip 3 | where {$_ -ne ""} | set-content d:\UTIL\scripts\serverlist1.txt

$content = Get-Content d:\UTIL\scripts\serverlist1.txt
$content | Foreach {$_.TrimEnd()} | Set-Content d:\UTIL\scripts\serverlist.txt

##### Done cleansing #####

d:\UTIL\scripts\SystemUptime1.ps1 > servers_restarted.txt


##### Report section ######

$not_contacted_count = 0
	$reader = New-Object IO.StreamReader 'd:\UTIL\scripts\not_contacted.txt'
	while ($reader.ReadLine() -ne $null){ $not_contacted_count++ }
	$reader.Close()

$not_restarted_count = 0
	$reader = New-Object IO.StreamReader 'd:\UTIL\scripts\not_restarted.txt'
	while ($reader.ReadLine() -ne $null){ $not_restarted_count++ }
	$reader.Close()

$restarted_count = 0
	$reader = New-Object IO.StreamReader 'd:\UTIL\scripts\restarted.txt'
	while ($reader.ReadLine() -ne $null){ $restarted_count++ }
	$reader.Close()


$total_not_contacted = ($not_contacted_count-1)
$total_not_restarted = ($not_restarted_count-1)
$total_restarted = ($restarted_count-1)
$total_checked = ($total_not_restarted+$total_restarted)


write-output "" > d:\util\scripts\servers_restarted.txt

write-output "" > d:\util\scripts\servers_restarted.txt

write-output "Servers that have been restarted within $timevariable days" >> d:\util\scripts\servers_restarted.txt

write-output "Server restart status for SCCM Collection: $collection" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Total servers checked = $total_checked" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Servers that could not be contacted:" >> d:\util\scripts\servers_restarted.txt

get-content d:\util\scripts\not_contacted.txt >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Total servers not contacted = $total_not_contacted" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Servers that have not restarted within 2 days:" >> d:\util\scripts\servers_restarted.txt

get-content d:\util\scripts\not_restarted.txt >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Total servers not restarted within 2 days = $total_not_restarted" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt
write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Servers that have restarted within 2 days:" >> d:\util\scripts\servers_restarted.txt

get-content d:\util\scripts\restarted.txt >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Total servers restarted = $total_restarted" >> d:\util\scripts\servers_restarted.txt

write-output "" >> d:\util\scripts\servers_restarted.txt

write-output "Server Uptime Information" >> d:\util\scripts\servers_restarted.txt

get-content d:\util\scripts\uptime.txt >> d:\util\scripts\servers_restarted.txt

##### End report #####

#send-mailmessage -SmtpServer notes29.mutualofomaha.com -from "Omahcsm04 <Will.Clark@mutualofomaha.com>" -to "Robert Swenson <Robert.Swenson@mutualofomaha.com>", "Roger Snyder <Roger.snyder@mutualofomaha.com>", "Will Clark <will.clark@mutualofomaha.com>", "Gary Hering <gary.hering@mutualofomaha.com>"  -subject "Server Restart from Collection: $collection" -body (Get-Content d:\util\scripts\servers_restarted.txt | out-string )

send-mailmessage -SmtpServer notes29.mutualofomaha.com -from "Benjamin Lupo <benjamin.lupo@mutualofomaha.com>" -to "Gary Hering <gary.hering@mutualofomaha.com>","Benjamin Lupo <benjamin.lupo@mutualofomaha.com>","Jason Willis <jason.willis@mutualofomaha.com>","Arunkumarreddy Yalate <arunkumarreddy.yalate@mutualofomaha.com>" -subject "Server Restart from Collection: $collection" -body (Get-Content d:\util\scripts\servers_restarted.txt | out-string )
