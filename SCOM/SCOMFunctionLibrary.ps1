Write-Host "BCBSNE SCOM PowerShell Function Library" -ForegroundColor Yellow -BackgroundColor DarkGray
Write-host "Version 1.0 " -ForegroundColor Yellow -BackgroundColor DarkGray
Write-host "=======================================" -ForegroundColor Yellow -BackgroundColor DarkGray

<# BCBSNE SCOM PowerShell Function Library

FUNCTION LIST

SET-SCOMENVIRONMENT
    Parameters: PRD TST TST DEV
    Connects your PowerShell session to the specified SCOM Management Server

GET-SCOMENVIRONMENT
    Parameters: {NONE}
    Returns the current Object for the SCOM Environment

DISCONECT-SCOMENVIRONMENT
    Parameters: {NONE}
    Disconnects the Powershell session from all connected SCOM Management Servers

PUSH-SCOMAGENT
    Parameters: <ServerFQDN>
    Install the SCOM Agent on the specified server

REMOVE-SCOMAGENT
    Parameters: <ServerFQDN>
    Removes the specified server from the SCOM Environment

SET-SCOMMM
GET-SCOMMM
REMOVE-SCOMMM
SCHEDULE-SCOMMM

FORCE-SCOMDISCOVERY

FIX-SCOMGRAYAGENT

GET-DOMAINNAME
    Parameters: <ServerFQDN>
    Returns an Object containing the Server, Domain, Environment

DETERMINE-SCOMENVIRONMENT
    Paramaters: <ServerFQDN>
    Returns the Server, Domain, Environment, SCOM Management Server, SCOM Management Group (if server is not found in any SCOM environment, returns "Server not found in SCOM Environment")

#>


#Import the OperationsManager module
Import-Module OperationsManager


####################################
#
# SCOM ENVIRONMENT FUNCTIONS     
#
####################################

# Connects to the specified SCOM Environment
# Valid Parameters are; PRD, TS1, DEV (or P, T, D)
Function Set-SCOMEnvironment([string]$SCOMManagementGroup)
{
    Get-SCOMManagementGroupConnection | Remove-SCOMManagementGroupConnection
    if ($SCOMManagementGroup -like "P*") {New-SCOMManagementGroupConnection -computername scomgt01prd.bcbsneprd.com}
    if ($SCOMManagementGroup -like "T*") {New-SCOMManagementGroupConnection -computername scomgt01ts1.bcbsneprd.com}
    if ($SCOMManagementGroup -like "D*") {New-SCOMManagementGroupConnection -computername scomgt01dev.bcbsneprd.com}
    return Get-SCOMEnvironment
}

# Returns the currently connect SCOM Management Group
Function Get-SCOMEnvironment
{
    return Get-SCOMManagementGroupConnection
}

# Disconnects from any/all currently connected SCOM Environments
Function Disconnect-SCOMEnvironment
{
    Get-SCOMManagementGroupConnection | Remove-SCOMManagementGroupConnection
}


# Get SCOM Environment Alert Status
Function Get-SCOMManagementInfo([string]$Environment)
{
    Set-SCOMEnvironment($Environment)
    $Alerts = Get-SCOMAlert
    $NewAlerts = $Alerts|where-object{$_.ResolutionState -eq '0'}
    $NewInfoAlerts = $Alerts|where-object{$_.Severity -eq 'Information' -and $_.ResolutionState -eq '0'}
    $NewWarningAlerts = $Alerts|where-object{$_.Severity -eq 'Warning' -and $_.ResolutionState -eq '0'}
    $NewErrorAlerts = $Alerts|where-object{$_.Severity -eq 'Error' -and $_.ResolutionState -eq '0'}

    $ClosedAlerts = $Alerts|where-object{$_.ResolutionState -eq '255'}
    $ClosedInfoAlerts = $Alerts|where-object{$_.Severity -eq 'Information' -and $_.ResolutionState -eq '255'}
    $ClosedWarningAlerts = $Alerts|where-object{$_.Severity -eq 'Warning' -and $_.ResolutionState -eq '255'}
    $ClosedErrorAlerts = $Alerts|where-object{$_.Severity -eq 'Error' -and $_.ResolutionState -eq '255'}

    write-host
    write-host "New Alerts: `t" $NewAlerts.Count
    write-host "-------------------------------"
    write-host "Informational: `t" $NewInfoAlerts.count
    write-host "Warning: `t`t" $NewWarningAlerts.count
    write-host "Error: `t`t`t" $NewErrorAlerts.count
    write-host
    write-host "Closed Alerts: `t" $ClosedAlerts.Count
    write-host "-------------------------------"
    write-host "Informational: `t" $ClosedInfoAlerts.count
    write-host "Warning: `t`t" $ClosedWarningAlerts.count
    write-host "Error: `t`t`t" $ClosedErrorAlerts.count
    write-host
    write-host "==============================="
    write-host "Total Alerts: `t" $Alerts.Count
}

####################################
#
# SCOM AGENT FUNCTIONS     
#
####################################

Function Push-SCOMAgent([string]$FQDN, [string]$ScomEnvironment)
{
    $PrimaryManagementServer = Set-SCOMEnvironment $ScomEnvironment
    $Creds = Get-Credential -Message "Enter Agent Install Credentials"

    $Results = Install-SCOMAgent -DNSHostName $FQDN -PrimaryManagementServer $PrimaryManagementServer -ActionAccount $Creds -PassThru 
    Return $Results
}

Function Remove-SCOMAgent([string]$FQDN)
{
    $AgentEnvironment = Determine-SCOMEnvironment $FQDN
    $AgentManagementServer = Set-SCOMEnvironment $AgentEnvironment.Environment
    $AgentID = Get-SCOMAgent -DNSHostName $AgentEnvironment.fqdn
    Uninstall-SCOMAgent -agent $AgentID -passthru
}

####################################
#
# SCOM MAINTENANCE MODE FUNCTIONS     
#
####################################

Function Set-SCOMMM
{

}


Function Get-SCOMMM
{

}


Function Remove-SCOMMM
{

}

Function Schedule-SCOMMM
{

}


####################################
#
# SCOM MISCELANEOUS FUNCTIONS     
#
####################################

# Forces SCOM to Resart Discovery of Objects on an Agent
Function Force-SCOMDiscovery ([string]$FQDN)
{
    Stop-Service -InputObject $(Get-Service -Computer $FQDN -Name HealthService)
    Start-Sleep -s 30
    clear-eventlog -Logname "Operations Manager" -ComputerName $FQDN
    Remove-Item “\\$FQDN\c$\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\*” -force -Recurse
    Start-Sleep -s 30
    Start-Service -InputObject $(Get-Service -Computer $FQDN -Name HealthService)
}

# Fixes SCOM Gray Agents
Function Fix-SCOMGrayAgent ([string]$FQDN)
{
    Stop-Service -InputObject $(Get-Service -Computer $FQDN -Name HealthService)
    Start-Sleep -s 30
    clear-eventlog -Logname "Operations Manager" -ComputerName $FQDN
    Remove-Item “\\$FQDN\c$\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\*” -force -Recurse
    Start-Sleep -s 30
    Start-Service -InputObject $(Get-Service -Computer $FQDN -Name HealthService)
}



####################################
#
# LIBRARY SUPPORTING FUNCTIONS     
#
####################################

Function Get-DomainName([string]$FQDN)
{
    $Server = @()
    
    $EnvironmentPosition = $FQDN.indexof(".")
    $NameLength = $FQDN.length
    $ComputerName = $FQDN.substring(0,$EnvironmentPosition)
    $Domain = $FQDN.substring(($EnvironmentPosition +1),(($FQDN.length)-($EnvironmentPosition+1)))
    $Environment = ($ComputerName).Substring(((($ComputerName).Length)-3),3)
    
    $Object = New-Object -TypeName PSObject
    $Object | Add-Member -Name 'FQDN' -MemberType Noteproperty -Value $FQDN.ToUpper()
    $Object | Add-Member -Name 'ComputerName' -MemberType Noteproperty -Value $ComputerName.ToUpper()
    $Object | Add-Member -Name 'Domain' -MemberType Noteproperty -Value $Domain.ToUpper()
    $Object | Add-Member -Name 'Environment' -MemberType Noteproperty -Value $Environment.ToUpper()
    $Server += $Object

    Return $Server
}

Function Determine-SCOMEnvironment([string]$FQDN)
{
    $Server = @()
    $Agent = $null
    $Computer = Get-DomainName $FQDN

    if (($Computer.Environment -eq "PRD") -or ($Computer.Environment -like "TS*") -or ($Computer.Environment -eq "DEV"))
    {
        $SCOMEnvironment = Set-SCOMEnvironment ($Computer.Environment)
        $Agent = Get-SCOMAgent -computername $SCOMEnvironment.ManagementServerName | where {$_.DisplayName -eq $Computer.FQDN}
    }
    Else
    {
        $SCOMEnvironments = "P","T","D"
        Foreach ($SCOMENV in $SCOMEnvironments)
        {
            $SCOMEnvironment = Set-SCOMEnvironment ($SCOMENV)
            $Agent = Get-SCOMAgent -computername $SCOMEnvironment.ManagementServerName | where {$_.DisplayName -eq $Computer.FQDN}
            If($Agent -ne $Null) {break}

        }
    }
    Disconnect-SCOMEnvironment

    If ($Agent -ne $Null) 
    {
        $Object = New-Object -TypeName PSObject
        $Object | Add-Member -Name 'FQDN' -MemberType Noteproperty -Value $Computer.FQDN
        $Object | Add-Member -Name 'ComputerName' -MemberType Noteproperty -Value $Computer.ComputerName
        $Object | Add-Member -Name 'Domain' -MemberType Noteproperty -Value $Computer.Domain
        $Object | Add-Member -Name 'Environment' -MemberType Noteproperty -Value $Computer.Environment
        $Object | Add-Member -Name 'SCOMManagementServer' -MemberType Noteproperty -Value ($SCOMEnvironment.ManagementServerName).toupper()
        $Object | Add-Member -Name 'SCOMManagementGroup' -MemberType Noteproperty -Value ($SCOMEnvironment.ManagementGroupName).toupper()
        $Server += $Object

        Return $Server
    }
    Else
    {
        Return "Server not found in SCOM Environment"
    }
}
