
### Same as "ping -t"
$pingHost = Read-Host "Enter host or IP to CONTINUOUS ping:"

while ($true) {

Test-Connection $pingHost

}

### Will ping until server goes down
$pingHost = Read-Host "Enter host or IP to ping until reboot:"

Do{

Test-Connection $pingHost

} until ($false)