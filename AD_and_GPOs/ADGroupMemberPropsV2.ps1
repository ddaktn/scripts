### Doug Nelson 09/06/2017

### Script will pull back USER members of AD group and select provided properties for the accounts ###
### Last changed 09/06/2017; ran against 'srvadmtier3' group for PCI audit information ###

# Put group name in variable
$Group = Get-ADGroup -Filter {name -like 'VDI-Pool*'}

Get-ADGroupMember -Identity $Group -Recursive | 
foreach { 
    Get-ADUser -Identity $psitem.distinguishedName -Properties * | 
    select @{l='group';e={$Group}},name,givenname,surname,@{l='manager';e={(Get-ADUser(Get-ADUser $_ -property manager).manager).samaccountname}}
} | Format-Table
 export-csv 'D:\Util\Scripts\Output\ServerAdminTier3Report.csv'


 