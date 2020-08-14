
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
