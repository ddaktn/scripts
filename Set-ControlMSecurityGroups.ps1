#Doug Nelson 10/27/2017
### SCRIPT TO SET CONTROL-M PERMISSIONS ###

### Is this a Domain Controller? ###
If(Get-Service 'NTDS' -ErrorAction SilentlyContinue){

    Write-Host "This is a Domain Controller. The permission script will NOT run."

}Else{

    ### Stop Control-M Services ###
    Get-Service 'ctmag*' | Stop-Service
  
    ### Kill any current backup jobs ###
    if(Get-Process 'dsmc.exe'){
    Stop-Process 'dsmc.exe'
    }
      
    ### CREATE LOCAL GROUPS ###
 
    ## Create connection to local computer account database ##
    $comp = $env:COMPUTERNAME
    $cn = [ADSI]"WinNT://$comp"

    ## Call the CREATE method to create the "APPBTCH" group, and SETINFO method to write to local database ##
    $group = $cn.Create("Group","APPBTCH")
    $group.setinfo()

    ## Call the CREATE method to create the "SysMgt" group, and SETINFO method to write to local database ##
    $group = $cn.Create("Group","SysMgt")
    $group.setinfo()

    ## Call the CREATE method to create the "SQLSVC" group, and SETINFO method to write to local database ##
    $group = $cn.Create("Group","SQLSVC")
    $group.setinfo()


    ### ADD DOMAIN ACCOUNTS TO LOCAL GROUPS ###

    ## ADD PNTB003 TO LOCAL GROUPS ##
    $DomainUser = "PNTB003"
    $LocalGroups = "Backup Operators","Power Users","APPBTCH","SysMgt"
    $Computer = $env:COMPUTERNAME
    $Domain = $env:USERDOMAIN

    ForEach($LocalGroup in $LocalGroups){
        ([ADSI]"WinNT://$Computer/$LocalGroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$Domain/$DomainUser").path)
    }

    ## ADD PTNG001 TO LOCAL GROUPS ##
    $DomainUser = "PTNG001"
    $LocalGroups = "Backup Operators","Power Users","APPBTCH","SysMgt"
    $Computer = $env:COMPUTERNAME
    $Domain = $env:USERDOMAIN

    ForEach($LocalGroup in $LocalGroups){
        ([ADSI]"WinNT://$Computer/$LocalGroup,group").psbase.Invoke("Add",([ADSI]"WinNT://$Domain/$DomainUser").path)
    }

    ### Update Group Policy ###
    GPUpdate /force 

    ### Start Control-M Services ###
    Get-Service 'ctmag*' | Start-Service
}