[CmdletBinding()]
    Param(
        [Parameter(Mandatory, ValueFromPipeline, Position = 0)]
        [string]$Name
    )

Function Get-CyberArkCredentials {

    Begin {
        $CyberArkUri = 'https://omahcsm74.corp.mutualofomaha.com/AIMWebService/v1.1/AIM.asmx'
    }

    Process {

        $CyberArkXML = @"
<?xml version="1.0" encoding="utf-8"?>
<soap:Envelope xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/">
 <soap:Body>
    <GetPassword xmlns="https://tempuri.org/">
      <passwordWSRequest>
        <AppID>is_ucs</AppID>
        <Safe>A-SYS-IS_O365</Safe>
        <Folder>Root</Folder>
        <Object>$Name</Object>
        <Reason>Retrieving password for use in PowerShell script</Reason>
        <ConnectionTimeout>30</ConnectionTimeout>
      </passwordWSRequest>
    </GetPassword>
  </soap:Body>
</soap:Envelope>
"@

        $Data = Invoke-WebRequest -Uri $CyberArkUri -Body $CyberArkXML -ContentType 'text/xml' -Headers $CyberArkHeader -Method Post 

        $Username = (($Data.Content -split '<UserName>')[1] -split '</UserName>')[0]

        # $Password = (($Data.Content -split '<GetPasswordResult><Content>')[1] -split '</Content>')[0]

        $password = ConvertTo-SecureString (($Data.Content -split '<GetPasswordResult><Content>')[1] -split '</Content>')[0] -AsPlainText -Force

        New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Username, $Password

    }
}