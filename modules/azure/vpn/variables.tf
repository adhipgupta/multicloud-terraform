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
variable "vng_id" {
  description = "Azure Network Gateway ID"
}

variable "remote_psk" {
  description = "pre shared keys"
}