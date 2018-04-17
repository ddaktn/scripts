### Reset AD password

$newPasswordUser= Read-Host "User to Set Password for:"

$newPassword = (Read-Host -Prompt "Provide New Password" -AsSecureString); Set-ADAccountPassword -Identity $newPasswordUser -NewPassword $newPassword -Reset
