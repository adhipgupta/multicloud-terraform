/*
locals {
  cgw_ids = aws_customer_gateway.edgeRouterGw.*.id //[List of Customer GW IDs]
  vpn_connection_ids = aws_vpn_connection.vpnConn.*.id //[List of all VPN connections]
  //Given the Bandwith per route table, calculate the number of tunnels by doing ceil
  //( bw_per_routetable/bw_per_tunnel ). For example, for cnps_vpn_connections_bw_gbps = {"dev" = 2.5} and
  //bandwith_per_tunnel = 1, the number of connections will be ceil(2.5/1) = 3.
  cnps_list = flatten([for i,j in var.cnps_vpn_connections_bw_gbps: [for k in range(ceil(j/var.bandwith_per_tunnel)) : i]]) //Given {"prod" = 2.5, "dev" = 1 }; returns ["prod","prod","prod","dev"]
  total_vpn_connections = length(var.router_info) * length(local.cnps_list) //Given router_info = [rtr1,rtr2] will return (2*4=) 8.
  cgw_to_cnps_list = setproduct(local.cnps_list, local.cgw_ids) //All combinations of ["prod","prod","prod","dev"] * ["cgw1", "cgw2"]
  publicip_to_cnps_list = setproduct(local.cnps_list, var.router_info)
}
*/

locals {
  all_remote_cidrs = distinct([for i in var.remote_gws : i[1]])
}

resource "aws_customer_gateway" "cgw" {
  count      = length(var.remote_gws)
  bgp_asn    = var.bgp_asn
  ip_address = var.remote_gws[count.index][0]
  type       = "ipsec.1"
  tags = {
    Name = var.remote_gws[count.index][0]
  }
}

resource "aws_vpn_gateway" "vpn_gateway" {
  vpc_id = var.vpc_id
  tags = {
    Name = "vpn_gateway"
  }
}

resource "aws_vpn_connection" "vpnConn" {
  count               = length(aws_customer_gateway.cgw.*.id)
  customer_gateway_id = length(aws_customer_gateway.cgw.*.id) > 0 ? aws_customer_gateway.cgw.*.id[count.index] : ""
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  type                = "ipsec.1"
  static_routes_only  = true
}

resource "aws_vpn_connection_route" "vpnConnectionRoute" {
  count                  = length(aws_vpn_connection.vpnConn.*.id)
  destination_cidr_block = var.remote_gws[count.index][1]
  vpn_connection_id      = aws_vpn_connection.vpnConn[count.index].id
}

resource "aws_route" "remoteRoute" {
  count                  = length(local.all_remote_cidrs)
  route_table_id         = var.route_table_id
  destination_cidr_block = local.all_remote_cidrs[count.index]
  gateway_id             = aws_vpn_gateway.vpn_gateway.id
}




















/*
resource "azurerm_local_network_gateway" "azureGW" {
  count = length(var.aws_remote_gw)
  name                = concat("azureGw", count.index)
  location            = var.rg_location
  resource_group_name = var.rg_name

  # AWS VPN Connection public IP address
  gateway_address = aws_vpn_connection.vpnConn[count.index].tunnel1_address

  address_space = [
    # AWS VPC CIDR
    var.vpc_cidr
  ]
}



/*
resource "azurerm_local_network_gateway" "local_network_gateway_1_tunnel1" {
  name                = "local_network_gateway_1_tunnel1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  # AWS VPN Connection public IP address
  gateway_address = aws_vpn_connection.vpn_connection_1.tunnel1_address

  address_space = [
    # AWS VPC CIDR
    aws_vpc.vpc.cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "tunnel1" {
  count               = length(aws_vpn_connection.vpnConn.*.id)
  name                = concat("tunnel", count.index)
  location            = var.rg_location
  resource_group_name = var.rg_name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_1_tunnel1.id

  # AWS VPN Connection secret shared key
  shared_key = aws_vpn_connection.vpn_connection_1.tunnel1_preshared_key
}

# Tunnel from Azure to AWS vpn_connection_1 (tunnel2)
resource "azurerm_local_network_gateway" "local_network_gateway_1_tunnel2" {
  name                = "local_network_gateway_1_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  gateway_address = aws_vpn_connection.vpn_connection_1.tunnel2_address

  address_space = [
    aws_vpc.vpc.cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_1_tunnel2" {
  name                = "virtual_network_gateway_connection_1_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_1_tunnel2.id

  shared_key = aws_vpn_connection.vpn_connection_1.tunnel2_preshared_key
}

# Tunnel from Azure to AWS vpn_connection_2 (tunnel1)
resource "azurerm_local_network_gateway" "local_network_gateway_2_tunnel1" {
  name                = "local_network_gateway_2_tunnel1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  gateway_address = aws_vpn_connection.vpn_connection_2.tunnel1_address

  address_space = [
    aws_vpc.vpc.cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_2_tunnel1" {
  name                = "virtual_network_gateway_connection_2_tunnel1"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_2_tunnel1.id

  shared_key = aws_vpn_connection.vpn_connection_2.tunnel1_preshared_key
}

# Tunnel from Azure to AWS vpn_connection_2 (tunnel2)
resource "azurerm_local_network_gateway" "local_network_gateway_2_tunnel2" {
  name                = "local_network_gateway_2_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  gateway_address = aws_vpn_connection.vpn_connection_2.tunnel2_address

  address_space = [
    aws_vpc.vpc.cidr_block
  ]
}

resource "azurerm_virtual_network_gateway_connection" "virtual_network_gateway_connection_2_tunnel2" {
  name                = "virtual_network_gateway_connection_2_tunnel2"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type                       = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
  local_network_gateway_id   = azurerm_local_network_gateway.local_network_gateway_2_tunnel2.id

  shared_key = aws_vpn_connection.vpn_connection_2.tunnel2_preshared_key
}

resource "aws_customer_gateway" "customer_gateway_1" {
  bgp_asn = var.bgp_asn
  ip_address = data.azurerm_public_ip.azure_public_ip_1.ip_address
  type       = "ipsec.1"
}

resource "aws_customer_gateway" "customer_gateway_2" {
  bgp_asn = var.bgp_asn
  ip_address = data.azurerm_public_ip.azure_public_ip_2.ip_address
  type       = "ipsec.1"

  tags = {
    Name = "customer_gateway_2"
  }
}

# We will use information from this piece to finish the Azure configuration on the next Step
resource "aws_vpn_connection" "vpn_connections" {
  count = var.vpn_connections
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_1.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "vpn_connection_1"
  }
}

# We will use information from this piece to finish the Azure configuration on the next Step
resource "aws_vpn_connection" "vpn_connection_2" {
  vpn_gateway_id      = aws_vpn_gateway.vpn_gateway.id
  customer_gateway_id = aws_customer_gateway.customer_gateway_2.id
  type                = "ipsec.1"
  static_routes_only  = true

  tags = {
    Name = "vpn_connection_2"
  }
}

resource "aws_vpn_connection_route" "vpn_connection_route_2" {
  # Azure's vnet CIDR
  destination_cidr_block = var.vnet_cidr[0]
  vpn_connection_id      = aws_vpn_connection.vpn_connection_2.id
}

*/