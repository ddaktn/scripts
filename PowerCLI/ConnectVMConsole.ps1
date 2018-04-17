### Connect to a VM's console session (Need the latest PowerCLI installed)

Get-Module -ListAvailable -Name VM* | Import-Module
Connect-VIServer omahcsm81.corp.mutualofomaha.com
Connect-VIServer omahcsm07.corp.mutualofomaha.com
Open-VMConsoleWindow (get-VM | sort-object name | where-object { $_.PowerState -eq 'poweredon' } | Out-GridView -Title 'Select VMs to connect to the console' -passthru)
