### Doug Nelson 09/06/2017

### Script will pull back USER members of AD group and select provided properties for the accounts ###
### Last changed 09/06/2017; ran against 'srvadmtier3' group for PCI audit information ###

# Put group name in variable
$Group = 'srvadmtier3'

Get-ADGroupMember -Identity $Group | where {$_.objectclass -eq "user"} | 
foreach { 
Get-ADUser -Identity $psitem.distinguishedName -Properties name,givenname,surname,passwordlastset,passwordneverexpires | 
select name,givenname,surname,passwordlastset,passwordneverexpires
 } | export-csv 'D:\Util\Scripts\Output\ServerAdminTier3Report.csv'


 