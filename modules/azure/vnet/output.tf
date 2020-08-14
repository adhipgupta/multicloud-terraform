output "azure_gw_info" {
  value = setproduct(azurerm_public_ip.public_ips.*.ip_address, var.vnet_cidr)
}

output "azure_vng_id" {
  value = azurerm_virtual_network_gateway.virtual_network_gateway.id
}
output "rg_location" {
  value = azurerm_resource_group.rg.location
}

output "rg_name" {
  value = azurerm_resource_group.rg.name
}

output "vpn_gw_subnet_cidr" {
  value = azurerm_subnet.gw_subnet.id
}
