<#
    Set the DTC settings for vRA/vRO IaaS Windows servers
    Doug Nelson
    8/8/2018
#>
[CmdletBinding()]
    PARAM (
        [Parameter(Mandatory=$false,
                   Position=0)]
        [string[]]$computers
    )
FUNCTION Set-DTC{
    BEGIN {}
    PROCESS {
        if ($computers -ne "") {
            foreach ($computer in $computers) {
                Invoke-Command -Computer $computer -Scriptblock {
                    PARAM (
                        $using:computer
                    )
                    TRY {
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name LuTransactions -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccess -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessAdmin -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessClients -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessInbound -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessOutbound -Value 1
                        Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessTransactions -Value 1
                        "The DTC settings were successfully changed on $using:computer."
                    }
                    CATCH {
                        "DID NOT SUCCESSFULLY CHANGE THE DTC SETTINGS ON $using:computer!"
                    }
                }
            }
        } else {
            TRY {
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name LuTransactions -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccess -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessAdmin -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessClients -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessInbound -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessOutbound -Value 1
                Set-ItemProperty -Path HKLM:\SOFTWARE\Microsoft\MSDTC\Security -Name NetworkDtcAccessTransactions -Value 1
                "The DTC settings on the local computer were successfully set"
            }
            CATCH {
                "THE DTC SETTINGS ON THE LOCAL COMPUTER WERE NOT SUCCESSFULLY SET!"
            }
        }
    }
    END {}
}
Set-DTC $computers