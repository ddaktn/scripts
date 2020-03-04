<#
# Variables for common values
$rgName = 'HubSpokeTest_rg'
$location = 'centralus'

# Create a resource group.
New-AzResourceGroup `
    -Name $rgName `
    -Location $location

# Create HUB virtual network.
$vnetHub = New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -Name 'Vnet_Hub' `
    -AddressPrefix '10.0.0.0/16' `
    -Location $location

# Create SPOKE virtual network A.
$vnetSpokeA = New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -Name 'Vnet_Spoke_A' -AddressPrefix '10.1.0.0/16' `
    -Location $location

# Create SPOKE virtual network B.
$vnetSpokeB = New-AzVirtualNetwork `
    -ResourceGroupName $rgName `
    -Name 'Vnet_Spoke_B' `
    -AddressPrefix '10.2.0.0/16' `
    -Location $location

#>

# Peer SPOKE A and SPOKE B to HUB.
Add-AzVirtualNetworkPeering -Name 'LinkSpokeAToHub' -VirtualNetwork $vnetSpokeA -RemoteVirtualNetworkId $vnetHub.Id
Add-AzVirtualNetworkPeering -Name 'LinkSpokeBToHub' -VirtualNetwork $vnetSpokeB -RemoteVirtualNetworkId $vnetHub.Id

# Peer HUB to SPOKE A and SPOKE B.
Add-AzVirtualNetworkPeering -Name 'LinkHubToSpokeA' -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetSpokeA.Id
Add-AzVirtualNetworkPeering -Name 'LinkHubToSpokeB' -VirtualNetwork $vnetHub -RemoteVirtualNetworkId $vnetSpokeB.Id

<#
# Create firewall subnet on HUB virtual network
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name 'firewall_SN' `
    -AddressPrefix 10.0.0.0/24 `
    -VirtualNetwork $vnetHub

# Associate firewall subnet on HUB virtual network
$vnetHub | Set-AzVirtualNetwork 

# Create default subnet on SPOKE A virtual network
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name 'default' `
    -AddressPrefix 10.1.0.0/24 `
    -VirtualNetwork $vnetSpokeA

# Associate firewall subnet on HUB virtual network
$vnetSpokeA | Set-AzVirtualNetwork

# Create default subnet on SPOKE B virtual network
$subnetConfig = Add-AzVirtualNetworkSubnetConfig `
    -Name 'default' `
    -AddressPrefix 10.2.0.0/24 `
    -VirtualNetwork $vnetSpokeB

# Associate firewall subnet on HUB virtual network
$vnetSpokeB | Set-AzVirtualNetwork
#>