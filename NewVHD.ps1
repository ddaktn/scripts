###Needs to have the Hyper-V module installed

###Install-WindowsFeature -Name hyper-v-powershell

New-VHD -Path C:\mydata2.vhdx -Dynamic -SizeBytes 10Gb |
Mount-VHD -Passthru |
Initialize-Disk -Passthru |
New-Partition -AssignDriveLetter -UseMaximumSize |
Format-Volume -FileSystem NTFS
