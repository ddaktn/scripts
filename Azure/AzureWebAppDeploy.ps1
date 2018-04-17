### Define Deployment Variables

$subscriptionName = 'bcbsne.corp.test'
$resourceGroupName = 'Doug-arm-paas-test'
$resourceProviderNamespace = 'Microsoft.Web'
$resourceTypeName = 'sites'
$resourceGroupLocation = 'West US'

$appNamePrefix = 'BCBSNEDougTest'
$appServicePlanName = $appNamePrefix
$webAppName = $appNamePrefix

### Set ARM Subscription

Get-AzureRMSubscription -SubscriptionName $subscriptionName | `
Select-AzureRmSubscription

### Get ARM Provider Locations

((Get-AzureRmResourceProvider `
    -ProviderNamespace "$resourceProviderNamespace").ResourceTypes | `
    Where-Object {$_.ResourceTypeName -eq "$resourceTypeName"}).Locations | `
    Sort-Object

### Create ARM Resource Group

New-AzureRmResourceGroup `
    -Name $resourceGroupName `
    -Location $resourceGroupLocation `
    -verbose -force

### Create App Service Plan

$appServicePlan = New-AzureRmAppServicePlan `
    -ResourceGroupName $resourceGroupName `
    -Location $resourceGroupLocation `
    -Name $appServicePlanName `
    -Tier Standard `
    -WorkerSize Small `
    -Verbose

### Create Web App

New-AzureRmWebApp `
    -ResourceGroupName $resourceGroupName `
    -Location $resourceGroupLocation `
    -AppServicePlan $appServicePlan.ServerFarmWithRichSkuName `
    -Name $webAppName `
    -Verbose
