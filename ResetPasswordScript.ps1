<######################################################################
Script to reset a domain password
Script will:
    a) prompt for username and password IF NOT PROVIDED
    b) convert the password to a secure string
    c) Set the provided account's password to the provided password
Doug Nelson
2/20/2018
######################################################################>

#region --> param block
PARAM(
[string]$newPasswordUser,
[string]$newPassword
)
#endregion


#region --> Prompt and create username variable IF NOT PROVIDED
if($newPasswordUser -eq ""){
    Write-Host "Username: " -NoNewline -ForegroundColor Yellow
    $newPasswordUser = Read-Host
}
#endregion


#region --> Prompt and create secure string password IF NOT PROVIDED
if($newPassword -eq ""){
    $newPassSecureString = Read-Host -Prompt "Enter new password: " -AsSecureString
} else {
    #Convert plain text password to secure string IF PROVIDED
    $newPassSecureString = ConvertTo-SecureString $newPassword -AsPlainText -Force
}
#endregion


#region --> Set the password
Set-ADAccountPassword -Identity $newPasswordUser -NewPassword $newPassSecureString -Reset
#endregion
