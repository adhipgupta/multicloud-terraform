variable "rg_name" {
  description = "Azure Resource Group Name"
}
variable "rg_location" {
  description = "Azure Resource Group Location "
}
variable "vnet_cidr" {
  description = "VNET Cidr block"
}
variable "vnet_name" {
  description = "VNET Name"
}
variable "subnet_names" {
  description = "List of Subnet names"
}
variable "subnet_list" {
  description = "List of Subnet prefixes"
}
variable "gw_subnet_cidr" {
  description = "Azure VPN Gateway needs a dedicated subnet. CIDR block for that subnet"
}
variable "username" {
  description = "Azure VM Username"
}
variable "password" {
  description = "Azure VM password"
}