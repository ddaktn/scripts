#Recursively get group membership by using get-aduser and distinguished name of group

Get-ADUser -Filter {memberOf -recursivematch 'cn=Domain Admins,cn=Users,dc=BCBSNEPRD,dc=com'}
