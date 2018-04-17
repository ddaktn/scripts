#Recursively get group membership by using get-aduser and distinguished name of group

Get-ADUser -Filter {memberOf -recursivematch 'cn=Domain Admins,ou=Security Groups,ou=Groups,dc=corp,dc=mutualofomaha,dc=com'} | select name
