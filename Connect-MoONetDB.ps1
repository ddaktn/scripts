## Create connection string variables ##
$MySQLAdminUserName = 'moonetauto'
$MySQLAdminPassword = 'CrescentMoon11'
$MySQLDatabase = 'MoOnet'
$MySQLHost = 'lx026'
$ConnectionString = "server=" + $MySQLHost + ";port=3306;uid=" + $MySQLAdminUserName + ";pwd=" + $MySQLAdminPassword + ";database="+$MySQLDatabase

## Load the Connector/Net assembly/dll into session ##
[void][System.Reflection.Assembly]::LoadWithPartialName("MySql.Data")

## Connect to the actual MySql database ##
$Connection = New-Object MySql.Data.MySqlClient.MySqlConnection
$Connection.ConnectionString = $ConnectionString
$Connection.Open()