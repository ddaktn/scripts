### Find local admin password for AD machines ###
Write-Host "Enter AD computer name to retrieve local admin password: " -NoNewline -ForegroundColor Yellow
$ADComputer = Read-Host
$LocalPassword = Get-ADComputer -Identity $ADComputer -Properties * | select -ExpandProperty ms-Mcs-AdmPwd
$LocalPassword