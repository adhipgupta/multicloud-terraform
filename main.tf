provider "azurerm" {
  skip_provider_registration = true
  features {}
}

provider "aws" {
  region = "us-east-1"
}

variable "azure_username" {}
variable "azure_password" {}
variable "aws_local_public_key" {}

module "azureRg" {
  source         = "./modules/azure/vnet/"
  rg_location    = "westus2"
  rg_name        = "multiCloud-Azure"
  vnet_cidr      = ["100.0.0.0/16"]
  subnet_list    = ["100.0.0.0/24"]
  subnet_names   = ["AzureGwsubnet1"]
  vnet_name      = "AzureVnet1"
  gw_subnet_cidr = "100.0.1.0/24"
  username       = var.azure_username
  password       = var.azure_password
}

module "awsVpc" {
  source       = "./modules/aws/vpc/"
  cidr         = "10.0.0.0/16"
  subnet_names = { "10.0.0.0/24" : "awsSubnet1" }
  subnet_zones = { "10.0.0.0/24" : "us-east-1b" }
  tags = {
    "Name" = "awsMultiCloudVpc1"
  }
  public_key = var.aws_local_public_key
  ami        = "ami-0b161e951484253ab"
}

module "awsVpn" {
  source         = "./modules/aws/vpn/"
  remote_gws     = module.azureRg.azure_gw_info
  route_table_id = module.awsVpc.route_table_id
  vpc_cidr       = "10.0.0.0/16"
  vpc_id         = module.awsVpc.vpc_id
  bgp_asn        = 65000
}

module "azureVpn" {
  source          = "./modules/azure/vpn/"
  rg_location     = module.azureRg.rg_location
  rg_name         = module.azureRg.rg_name
  remote_cidr     = "10.0.0.0/16"
  remote_vpnconns = module.awsVpn.aws_tunnel_info_address
  remote_psk      = module.awsVpn.aws_tunnel_info_psk
  vng_id          = module.azureRg.azure_vng_id
}
