# Post Patching Server Check
#
# Chris Barnard
# 10/7/2014

#Import the OperationsManager module
Import-Module OperationsManager

# Get list of Servers
$Agents = Get-ScomAgent | sort-object displayname 

# Define Newest Event Counter
$NewestEventCounter = 0

#Create variables for sending email
$EmailSMTPServer = "mailrelay.business.com"
$EmailSender = "PS_SCOM_Automation@Business.com"
$EmailRecipient = "Email@business.com"
$EmailSubject = "Post Patching Server Check Report"
$EmailBody = " "

#Create variables for Report
$EmailReportHeader = " "
$EmailReportSummary = " "
$EmailReportDetail = " "
$EmailReportFooter = " "
$EmailReportScriptFailures = " "
$ReportAgentCount = $Agents.count

# Clear the Screen
cls

# Clear $error Variable
$Error.clear()

Write-Host ("Start : " + (Get-Date))
$StartTime = Get-Date
write-host "-------------------------------"

$EmailReportSummary = "Servers with patches waiting " + "`r`n`r`n"
$EmailReportDetail = "Servers and Patch Detail " + "`r`n`r`n"
$EmailReportScriptFailures = "Servers with issues " + "`r`n`r`n"


foreach ($Agent in $Agents)
{
    do
    {
        $NewestEventCounter = $NewestEventCounter + 100
        $SystemEventLogReboot = get-eventlog system -ComputerName $Agent.DisplayName -Newest $NewestEventCounter | where {$_.EventID -eq 6006}
        if ($NewestEventCounter -gt 6000)
        {
            $EmailReportScriptFailures = $EmailReportScriptFailures + [string]$Agent.Name + " - Failed to find Reboot " + "`r`n`r`n"
            Write-host "NO REBOOT FOUND : " $Agent.Name
            break
        }
        if ($error.count -ne 0)
        {
            $EmailReportScriptFailures = $EmailReportScriptFailures + [string]$Agent.Name + " - Unable to connect to server via powershell " + "`r`n`r`n"
            Write-host "FAILDED CONNECTING TO SERVER : " $Agent.Name
            $error.clear()
        }
        
    } while ($SystemEventLogReboot -eq $Null)

        write-host ($Agent.Name + " - Event Counter : " + [string]$NewestEventCounter + " - Last Reboot Date / Time : " + [string]$SystemEventLogReboot.TimeGenerated[0])

        $SystemEventLogEntries = get-eventlog system -ComputerName $Agent.DisplayName  -newest $NewestEventCounter | where {(($_.eventid -eq 17 -or $_.eventid -eq 18) -and $_.source -eq "Microsoft-Windows-WindowsUpdateClient")}
    
        foreach ($SystemEventLogEntry in $SystemEventLogEntries)
        {
       
            if ($SystemEventLogEntry.timegenerated.datetime -gt $SystemEventLogReboot.TimeGenerated[0].datetime)
                {   
                    Write-host " "
                    Write-host "********** PATCH WAITING ***********"
                    Write-host ($Agent.Name + " - Event Log Entry : " + $SystemEventLogEntry.Message)
                    Write-host "********** PATCH WAITING ***********"
                    Write-Host " "
                    $EmailReportSummary = $EmailReportSummary + [string]$Agent.Name + "`r`n`r`n"
                    $EmailReportDetail = $EmailReportDetail + [string]$Agent.Name + "`r`n`r`n"
                    $EmailReportDetail = $EmailReportDetail + $SystemEventLogEntry.message + "`r`n`r`n"
                    $EmailReportDetail = $EmailReportDetail + "...................................." + "`r`n"
                    Break
                }    
                Else
                {
                    #Write-Host "No Patches Waiting"
                    #write-host "LastBoot : " + $SystemEventLogReboot.TimeGenerated[0].datetime
                    #write-host "Event    : " + $SystemEventLogEntry.timegenerated.DateTime
                    #Write-host " "
                }
    }
    # Reset Newest Event Counter
    $NewestEventCounter = 0       
}

$EndTime = Get-Date
Write-Host ("Start : " + $StartTime)
Write-Host ("End : " + $EndTime)
write-host "-------------------------------"

#Build Report Header
$EmailReportHeader = "Post Patching Server Check Report" + "`r`n"
$EmailReportHeader = $EmailReportHeader + "`r`n"
$EmailReportHeader = $EmailReportHeader + "Start Date / Time : " + $StartTime + "`r`n"
$EmailReportHeader = $EmailReportHeader + "End Date / Time : " + $EndTime + "`r`n"
$EmailReportHeader = $EmailReportHeader + "`r`n"
$EmailReportHeader = $EmailReportHeader + "Total Servers Checked : " + $ReportAgentCount + "`r`n"

#Build Report Footer
$EmailReportFooter = "Core Infrastructure Services - Blue Cross Blue Shield of Nebraska" + "`r`n"


# Build Email Message 
$EmailBody = $EmailBody + $EmailReportHeader + "`r`n"
$EmailBody = $EmailBody + "============================================" + "`r`n"
$EmailBody = $EmailBody + $EmailReportSummary + "`r`n"
$EmailBody = $EmailBody + "--------------------------------------------" + "`r`n"
$EmailBody = $EmailBody + $EmailReportScriptFailures + "`r`n"
$EmailBody = $EmailBody + "--------------------------------------------" + "`r`n"
$EmailBody = $EmailBody + $EmailReportDetail + "`r`n"
$EmailBody = $EmailBody + "============================================" + "`r`n"
$EmailBody = $EmailBody + $EmailReportFooter + "`r`n"

# Send Report via email
Send-MailMessage -to $EmailRecipient -from $EmailSender -Subject $EmailSubject -SmtpServer $EmailSMTPServer -Body $EmailBody
