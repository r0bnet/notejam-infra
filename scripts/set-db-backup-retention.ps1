[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId
    [Parameter(Mandatory=$true)]
    [string]
    $MssqlResourceGroupName
    [Parameter(Mandatory=$true)]
    [string]
    $MssqlServerName
    [Parameter(Mandatory=$true)]
    [string]
    $MssqlDbName
)

Connect-AzAccount
Select-AzSubscription -SubscriptionId $SubscriptionId

$server = Get-AzSqlServer -ServerName $MssqlServerName -ResourceGroupName $MssqlResourceGroupName

Set-AzSqlDatabaseBackupLongTermRetentionPolicy -ServerName $MssqlServerName -DatabaseName $MssqlDbName `
    -ResourceGroupName $MssqlResourceGroupName -WeeklyRetention P4W -YearlyRetention P3Y -WeekOfYear 1 -MonthlyRetention P12M