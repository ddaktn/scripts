###Convert the COLLECTION of "members" to a string value (a string can only be compared to a string) by declaring it a string (with [string]) and use an empty string value ("")
Get-ADGroup -SearchBase "OU=Environments,DC=BCBSNEPRD,DC=com" -Filter * -Properties Members | Where {[string]$_.members -eq ""} | select name | measure

###Compare the VALUE of "members" to $null by adding '.value' to end of the array
Get-ADGroup -SearchBase "OU=Environments,DC=BCBSNEPRD,DC=com" -Filter * -Properties Members | Where {$_.members.value -eq $null} | select name | measure


Get-ADGroup -SearchBase "OU=Environments,DC=BCBSNEPRD,DC=com" -Filter * -Properties Members | Where {-not $_.members} | 
select name | sort name | export-csv C:\users\Douglas.Nelson\Desktop\EmptyGroups.csv -NoTypeInformation


###https://social.technet.microsoft.com/Forums/windowsserver/en-US/0ba5f10d-465f-467b-ba97-a0a9517f00e8/how-do-i-check-for-an-empty-sidhistory-attribute-in-a-ad-user?forum=winserverpowershell

###https://powershell.org/forums/topic/difference-between-null-and/
