output "aws_tunnel1_info" {
  value = {
    "psk" : aws_vpn_connection.vpnConn.*.tunnel1_preshared_key,
    "address" : aws_vpn_connection.vpnConn.*.tunnel1_address
  }
}

output "aws_tunnel2_info" {
  value = {
    "psk" : aws_vpn_connection.vpnConn.*.tunnel2_preshared_key,
    "address" : aws_vpn_connection.vpnConn.*.tunnel2_address
  }
}

output "aws_connections" {
  value = aws_vpn_connection.vpnConn.*.id
}

output "aws_connection_info" {
  value = setproduct(aws_vpn_connection.vpnConn.*.id, [var.vpc_cidr])
}

output "aws_tunnel_info_address" {
  value = setproduct(concat(aws_vpn_connection.vpnConn.*.tunnel1_address, aws_vpn_connection.vpnConn.*.tunnel2_address), [var.vpc_cidr])
}

output "aws_tunnel_info_psk" {
  value = concat(aws_vpn_connection.vpnConn.*.tunnel1_preshared_key, aws_vpn_connection.vpnConn.*.tunnel2_preshared_key)
}

