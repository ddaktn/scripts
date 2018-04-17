

### List all running and configured (at creation) OS versions (per vmtools) ###
Get-VM | Sort | Get-View -Property @("Name", "Config.GuestFullName", "Guest.GuestFullName") | Select -Property Name, @{N="Configured OS";E={$_.Config.GuestFullName}},  @{N="Running OS";E={$_.Guest.GuestFullName}} | Format-Table -AutoSize


### Dump it into a CSV ###
Get-VM | Sort-Object -Property Name |
Get-View -Property @("Name", "Config.GuestFullName", "Guest.GuestFullName") |
Select -Property Name,
    @{N="Configured OS";E={$_.Config.GuestFullName}}, 
    @{N="Running OS";E={$_.Guest.GuestFullName}} |
Export-Csv report.csv -NoTypeInformation -UseCulture



### get a count for each running OS ###

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "CentOS 4/5/6/7*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Debian GNU/Linux 5*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "FreeBSD*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Microsoft Windows 7*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Microsoft Windows Server 2003*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Microsoft Windows Server 2008*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Microsoft Windows Server 2012*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Oracle Linux 4/5/6/7*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Oracle Solaris*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Red Hat Enterprise Linux 4*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Red Hat Enterprise Linux 5*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Red Hat Enterprise Linux 6*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Red Hat Enterprise Linux 7*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "SUSE Linux Enterprise 11*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "SUSE Linux Enterprise 12*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Ubuntu*"} | measure

Get-VM | Sort-Object -Property Name | Get-View -Property @("Name","Config.GuestFullName","Guest.GuestFullName") | where {$_.Config.GuestFullName -like "Other*"} | measure


