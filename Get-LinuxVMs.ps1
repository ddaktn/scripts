Import-Module VMware.VimAutomation.Core
Connect-VIServer omahcsm07.corp.mutualofomaha.com

Get-VM | where {$_.name -like 'lx*'} | select name,'Num CPUs',MemoryGB | export-csv C:\temp\ListLinuxVMs.csv -NoTypeInformation
