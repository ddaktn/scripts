### Find local admin password for 2016 servers ###
Write-Host "Enter 2016 servername to retrieve local admin password: " -NoNewline -ForegroundColor Yellow
$ADComputer = Read-Host
$LocalPassword = Get-ADComputer -Identity $ADComputer -Properties * | select -ExpandProperty ms-Mcs-AdmPwd
$LocalPassword