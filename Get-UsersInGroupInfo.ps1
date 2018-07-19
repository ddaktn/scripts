$groups = Get-ADGroup -Filter {name -like "VDI-Pool*"}

$output = ForEach ($g in $groups){
    $results = Get-ADGroupMember -Identity $g.name -Recursive | Get-ADUser -Properties Name, Description, Office, Manager
    ForEach ($r in $results){
        New-Object PSObject -Property @{
            VDIPool = $g.Name
            User = $r.SamAccountName
            Description = $r.Description
            Office = $r.Office
            Manager = ( get-aduser ( get-aduser $r -Property manager ).manager).samaccountname        
        }
    }
} 
 $output | Export-Csv -path c:\temp\output.csv
