<#
Script to remove Windows Feature if it exists
Doug Nelson
3/2/2018
#>

PARAM(
    [string]$serverName,
    [string]$role,
    [switch]$remove,
    [switch]$install   
)

#region if server name was not provided as parameter, prompt for server name
if($serverName -eq ""){
    Write-Host "Enter server name to remove role/feature on: " -NoNewline -ForegroundColor Yellow
    $serverName = Read-Host
}
#endregion

#region create role variable if not provided as parameter
if($role -eq ""){
    Write-Host "Are you installing/removing the Failover-Clustering role from server $serverName" -ForegroundColor Yellow
    Write-Host "0 - YES" -ForegroundColor Yellow
    Write-Host "1 - NO" -ForegroundColor Yellow
    $roleChoice = Read-Host
    if($roleChoice -eq 0){
        $role = "Failover-Clustering"
    } elseif($roleChoice -eq 1){
        Write-Host "Enter the role you are installing or removing" -ForegroundColor Yellow
        $role = Read-Host
    }
}
#endregion

#region if the remove or install actions were not provided as parameters, prompt for action
if($remove -eq $false -and $install -eq $false){
    Write-Host "Are you installing or removing the role/feature on server $serverName" -ForegroundColor Yellow
    Write-Host "0 - REMOVING" -ForegroundColor Yellow
    Write-Host "1 - INSTALLING" -ForegroundColor Yellow
    $answer = Read-Host "Enter the number for desired action"
    if($answer -eq 0){
        $remove = $true
        $install = $false
    } elseif($answer -eq 1){
        $install = $true
        $remove = $false
    }
}
#endregion

#region remove role
if($remove -eq $true){
    Invoke-Command -ComputerName $serverName -ScriptBlock {
        $using:serverName
        $using:role
        if(Get-WindowsFeature $using:role | where{$PSItem.Installed -eq $true}){
            Write-Host "The $using:role role/feature was found on server $using:serverName. It will now be removed."
            Remove-WindowsFeature $using:role -Confirm:$false
            Write-Host "The $using:role role/feature has been removed."
        } else {
            Write-Host "The $using:role role/feature was not found on server $using:serverName."
        }
    }
}
#endregion

#region install role
if($install -eq $true){
    Invoke-Command -ComputerName $serverName -ScriptBlock {
        $using:serverName
        $using:role
        if(Get-WindowsFeature $using:role | where{$PSItem.Installed -eq $true}){
            Write-Host "The $using:role role/feature was already installed on server $using:serverName."    
        } else {
            Write-Host "The $using:role role/feature was not found on server $using:serverName. It will now be installed."
            Add-WindowsFeature $using:role -Confirm:$false
            Write-Host "The $using:role role/feature has been installed."
        }
    }
}
#endregion