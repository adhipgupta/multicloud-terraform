resource "azurerm_local_network_gateway" "remotePeers" {
  count               = length(var.remote_vpnconns)
  name                = format("azureGw-%d", count.index)
  location            = var.rg_location
  resource_group_name = var.rg_name

  gateway_address = var.remote_vpnconns[count.index][0]
  address_space   = [var.remote_vpnconns[count.index][1]]
}

resource "azurerm_virtual_network_gateway_connection" "tunnels" {
  count               = length(var.remote_vpnconns)
  name                = format("tunnel-%d", count.index)
  location            = var.rg_location
  resource_group_name = var.rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = var.vng_id
  local_network_gateway_id   = azurerm_local_network_gateway.remotePeers[count.index].id

  shared_key = var.remote_psk[count.index]
}
