$ADComputers = get-adcomputer -filter * -SearchBase "DC=corp,DC=mutualofomaha,DC=com" -Properties CanonicalName,DistinguishedName, CN

$ComputerLocation = $ADComputers | select CN, @{Name='OU'; Expression={$_.CanonicalName.Replace('corp.mutualofomaha.com/','').Replace("/$($_.Name)",'')}}