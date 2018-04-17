<#########################################################################
    Script to get vm's WITHOUT vCPU and Memory HOT ADD
    Doug Nelson
    03/06/2018
    *** Script can be called with parameters or run interactively***
#########################################################################>

PARAM(
    [string]$vCenter,
    [string]$user,
    [string]$password,
    [switch]$windowsCloud,
    [switch]$windowsEarth    
)

#region
    Get-Module VM* -ListAvailable | Import-Module
    if($vCenter -eq ""){
        Write-Host "Specify which vCenter to check VMs for CPU/Memory Hot Add: " -ForegroundColor Yellow
        Write-Host "0 - ITG OMAHCSM81 environment" -ForegroundColor Yellow
        Write-Host "1 - PROD OMAHCSM07 environment" -ForegroundColor Yellow
        Write-Host "Enter the number for desired environment: " -ForegroundColor Yellow
        $vCenterChoice = Read-Host
            if($vCenterChoice -eq 0){
                if(($user -ne "") -and ($password -ne "")){
                    Connect-VIServer omahcsm81.corp.mutualofomaha.com -User $user -Password $password
                } else {
                    $creds = Get-Credential
                    Connect-VIServer omahcsm81.corp.mutualofomaha.com -Credential $creds
                } 
            } elseif($vCenterChoice -eq 1){
                if(($user -ne "") -and ($password -ne "")){
                    Connect-VIServer omahcsm07.corp.mutualofomaha.com -User $user -Password $password
                } else {
                    $creds = Get-Credential
                    Connect-VIServer omahcsm07.corp.mutualofomaha.com -Credential $creds
                }
            }
    }
#endregion

#region
    $arg1 = @{N="CpuHotAddEnabled";E={$_.Config.CpuHotAddEnabled}}
    $arg3 = @{N="MemoryHotAddEnabled";E={$_.Config.MemoryHotAddEnabled}}
    $wn = Get-VM -Name wn*
    $omah = Get-VM -Name omah*
    $all = $wn + $omah
    if(($windows -eq $false) -and ($linux -eq $false)){
        Write-Host "Specify cloud Windows or standard build Windows servers to check for Hot Add functionality: " -ForegroundColor Yellow
        Write-Host "0 - Cloud" -ForegroundColor Yellow
        Write-Host "1 - Standard Build" -ForegroundColor Yellow
        Write-Host "2 - BOTH Cloud AND Standard Build" -ForegroundColor Yellow
        Write-Host "Enter the number for server choice: " -ForegroundColor Yellow
        $serverChoice = Read-Host
            if($serverChoice -eq 2){
                $all | Get-View |
                    Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                        Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
            }elseif($serverChoice -eq 1){
                $omah | Get-View | 
                    Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                        Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
            }elseif($serverChoice -eq 0){
                $wn | Get-View | 
                    Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                        Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
            }   
    }elseif(($windowsCloud -eq $true) -and ($windowsEarth -eq $true)){
        $all | Get-View |
            Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
    }elseif($windowsEarth -eq $true){
        $omah | Get-View |
            Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
    }else{
        $wn | Get-View |
            Where-Object {($_.Config.CpuHotAddEnabled -eq $FALSE) -or ($_.Config.MemoryHotAddEnabled -eq $FALSE)} |
                Select-Object Name,$arg1,$arg3 | Sort-Object Name | Format-Table -AutoSize
    }
#endregion