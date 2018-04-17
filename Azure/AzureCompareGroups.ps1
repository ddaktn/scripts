$ADUsers = Get-ADGroupMember 'azureadsynced' | select name | sort name
$AzureUsers = Get-AzureRmADUser | select displayname | sort displayname

Compare-Object -ReferenceObject $ADUsers -DifferenceObject $AzureUsers -PassThru | export-csv C:\AzureDifferenceUsers.csv -NoTypeInformation

