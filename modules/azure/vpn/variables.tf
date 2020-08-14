variable "rg_name" {
  description = "Azure Resource Group Name"
}
variable "rg_location" {
  description = "Azure Resource Group Location "
}
variable "remote_vpnconns" {
  description = "List of Remote VPN connections"
}
variable "remote_cidr" {
  description = "Remote CIDRs"
}
/*
variable "tunnel1_info" {
  description = "Tunnel1 endpoint and psk information"
}
variable "tunnel2_info" {
  description = "Tunnel2 endpoint and psk information"
}
*/
variable "vng_id" {
  description = "Azure Network Gateway ID"
}

variable "remote_psk" {
  description = "pre shared keys"
}