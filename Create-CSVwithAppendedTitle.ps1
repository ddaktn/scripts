
### Create a CSV report with an appended title ###


$Group = 'Domain Admins'
$Date= Get-Date -Format d
$DateReportName = Get-Date -Format y
$Header = "$Group Membership Report on $Date"

Get-ADGroupMember -Identity $Group | where {$_.objectclass -eq "user"} | 

foreach { 
    Get-ADUser -Identity $psitem.distinguishedName -Properties name,givenname,surname,enabled,lastlogondate,passwordneverexpires,passwordlastset |
    select name,givenname,surname,enabled,lastlogondate,passwordneverexpires,passwordlastset,@{L="Date";E={$Date}}
} | Export-Csv -LiteralPath "\\omahcsb05\Scripts\User Accounts\$Group Report Export.csv" -NoTypeInformation

$csv = Get-Content "\\omahcsb05\Scripts\User Accounts\$Group Report Export.csv"
$Header | Out-File  "\\omahcsb05\Scripts\User Accounts\$Group Report $DateReportName.csv" -Encoding utf8
$csv | Out-File "\\omahcsb05\Scripts\User Accounts\Domain Admins Report December 2017.csv" -Append -encoding utf8