FUNCTION Change-NetAddress{
    [CmdletBinding()]
        Param(
            [Parameter(Mandatory=$True,
                       Position=0)]
            [string]$IP,

            [Parameter(Mandatory=$False,
                       Position=1)]
            [string]$MaskBits = 24,

            [Parameter(Mandatory=$True,
                       Position=2)]
            [string]$Gateway,

            [Parameter(Mandatory=$True,
                       Position=3)]
            [string]$Dns,

            [Parameter(Mandatory=$False,
                       Position=4)]
            [string]$IPType = "IPv4"
        )
        BEGIN{
            # Retrieve the network adapter that you want to configure
            $adapter = Get-NetAdapter | ? {$_.Status -eq "up"} 
        }
        PROCESS{
            # Remove any existing IP, gateway from our ipv4 adapter
            If (($adapter | Get-NetIPConfiguration).IPv4Address.IPAddress) {
                $adapter | Remove-NetIPAddress -AddressFamily $IPType -Confirm:$false
            }
            If (($adapter | Get-NetIPConfiguration).Ipv4DefaultGateway) {
                $adapter | Remove-NetRoute -AddressFamily $IPType -Confirm:$false
            }
            # Configure the IP address and default gateway
            $adapter | New-NetIPAddress `
                -AddressFamily $IPType `
                -IPAddress $IP `
                -PrefixLength $MaskBits `
                -DefaultGateway $Gateway
            # Configure the DNS client server IP addresses
            $adapter | Set-DnsClientServerAddress -ServerAddresses $DNS
        }
        END{}
}