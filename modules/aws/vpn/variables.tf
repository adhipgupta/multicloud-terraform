variable "bgp_asn" {
  description = "List of BGP ASNs of the remote end."
}

variable "route_table_id" {
  description = "Local route table ID in the VPC"
}
variable "vpc_id" {
  description = "VPC ID to which the VPN Gateway is connected to"
}
variable "vpc_cidr" {
  description = "VPC CIDR"
}
variable "remote_gws" {
  description = ""
}
