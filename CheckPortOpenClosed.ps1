### Script to check TCP and UDP port connectivity ###

## Create a variable for the remote machine to check connectivity to ##
Write-Host "Enter IP or hostname for port check:" -ForegroundColor Magenta
$RemoteMachine = Read-Host

## Create variable for the port to check connectivity with ##
Write-Host "Enter port to check:" -ForegroundColor Magenta
$Port= Read-host

## Create TCP object to check connections ##
$t = New-Object Net.Sockets.TcpClient

## Create UDP object to check connections ##
$u = New-Object Net.Sockets.UdpClient

## Script block to check TCP connectivity ##
$t.Connect($RemoteMachine,$Port)
    if($t.Connected)
    {
        Write-Host "TCP port $Port is operational" -ForegroundColor Green
    }else
    {
        Write-Host "!!!TCP port $Port is CLOSED!!!" -ForegroundColor Red
    }

## Script block to check UDP connectivity ##
$u.Connect($RemoteMachine,$Port)
    if($u.Connected)
    {
        Write-Host "UDP port $Port is operational" -ForegroundColor Green
    }else
    {
        Write-Host "!!!UDP port $Port is CLOSED!!!" -ForegroundColor Red
    }