<#
    Script to check TCP and UDP port connectivity
    Doug Nelson
    7/24/2018
#>

[CmdletBinding()]
    PARAM(
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string]$RemoteMachine,

        [Parameter(Mandatory=$false,
                   Position=1)]
        [string]$Port
    )
FUNCTION Check-PortConnect{
    BEGIN{
        $ErrorActionPreference = 'SilentlyContinue'
        if($RemoteMachine -eq ""){
            Write-Host "Enter IP or hostname for port check:" -ForegroundColor Magenta
            $RemoteMachine = Read-Host
        }
        if($Port -eq ""){
            Write-Host "Enter port to check:" -ForegroundColor Magenta
            $Port= Read-host
        }
        $t = New-Object Net.Sockets.TcpClient
        $u = New-Object Net.Sockets.UdpClient
    }
    PROCESS{
        ## Script block to check TCP connectivity ##
        $t.Connect($RemoteMachine,$Port)
            if($t.Connected){
                Write-Host "TCP port $Port is operational" -ForegroundColor Green
            } else {
                Write-Host "!!!TCP port $Port is CLOSED!!!" -ForegroundColor Red
            }
        ## Script block to check UDP connectivity ##
        $u.Connect($RemoteMachine,$Port)
            if($u.Connected){
                Write-Host "UDP port $Port is operational" -ForegroundColor Green
            } else {
                Write-Host "!!!UDP port $Port is CLOSED!!!" -ForegroundColor Red
            }
    }
    END{}
}
Check-PortConnect $RemoteMachine $Port