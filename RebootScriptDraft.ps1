Invoke-Command -ComputerName omahcsm04 -ScriptBlock {
### Create Secure String for password *** ONLY NEED TO RUN ONCE ###
#read-host -assecurestring | convertfrom-securestring | out-file '\\omahcsm04\d$\util\scripts\SecureString.txt'

### Create Password Variables (I used my account for testing)
#$username = "ntmaster\mss92473"
#$password = get-content 'd:\util\scripts\SecureString.txt' | ConvertTo-SecureString
#$cred = new-object -typename System.Management.Automation.PSCredential -argumentlist $username, $password
 
### Read in list of machines
$machines = Get-Content 'd:\util\scripts\serverlist.txt' 

### Create report arrays
$report = @() 
$object = @() 

### Run loop against machines in list pulling back machine name and last boot time
foreach($machine in $machines) 
{ 
$machine 
$object = Get-CimInstance win32_operatingsystem -ComputerName $machine | select PSComputerName,LastBootUpTime | sort LastBootUpTime
$report += $object 
}} 

$report


### Convert report array into string and mail report to listed users with credentials
Send-MailMessage -SmtpServer 10.16.6.12 `
-Subject "Server Maintenance Reboot List" `
-From "Doug Nelson <doug.nelson@mutualofomaha>" `
-to "Gary Hering<gary.hering@mutualofomaha.com>","Doug Nelson<doug.nelson@mutualofomaha.com>" `
-Body ($report | out-string) `
}