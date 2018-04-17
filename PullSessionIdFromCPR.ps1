$RawSessionID = Invoke-WebRequest -Uri "https://app.bcinthecloud.com/rest/api/login?loginName=doug.nelson@MutualofOmaha.com&password="
$output = $RawSessionID.Content
 Foreach($o in [xml]$output){
$SessionID = $o.resp.sessionId
}
Write-Host $SessionID


