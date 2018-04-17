### Restart Service on server ###

## Get credentials to run command ##
Write-Host "ENTER ADMIN CREDENTIALS:" -ForegroundColor Yellow
$Credential = Read-Host

## Use yellow font to get the remote server name ##
Write-Host "SERVER NAME:" -ForegroundColor Yellow
$computer = Read-Host

Invoke-Command -ComputerName $computer -Credential $Credential -ScriptBlock {

    ## Display all of the services and prompt for which to restart ##
    Get-Service 
    Write-Host "SERVICE TO RESTART:" -ForegroundColor Yellow
    $service = Read-Host 
    
    ## Stop the service with a verbose command and show it's status as stopped ##
    Stop-Service $service -Verbose
    Get-Service $service

    ## Start the service with a verbose command ##
    Start-Service $service -Verbose

    ## Validate that the command ran successfully by checking the service status ##
    if (get-service $service | where {$_.status -eq "Running"}){
        Get-Service $service
        write-host "SERVICE RESTARTED SUCCESSFULLY" -ForegroundColor Green
    }
    else{
        Get-Service $service
        write-host "!!!SERVICE DID NOT RESTART SUCCESSFULLY!!!" -ForegroundColor Red
    } 
}   
