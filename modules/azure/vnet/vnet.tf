resource "azurerm_resource_group" "rg" {
  name     = var.rg_name
  location = var.rg_location
}

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = var.vnet_cidr
}

resource "azurerm_subnet" "subnet" {
  count                = length(var.subnet_list)
  name                 = var.subnet_names[count.index]
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.subnet_list[count.index]
}

resource "azurerm_subnet" "gw_subnet" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefix       = var.gw_subnet_cidr
}

resource "azurerm_public_ip" "public_ips" {
  count               = 1
  name                = format("publicIp%d", count.index)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
  name                = "virtual_network_gateway"
  location            = var.rg_location
  resource_group_name = var.rg_name

  type       = "Vpn"
  vpn_type   = "RouteBased"
  sku        = "VpnGw1"
  enable_bgp = true

  ip_configuration {
    name                          = azurerm_public_ip.public_ips[0].name
    public_ip_address_id          = azurerm_public_ip.public_ips[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw_subnet.id
  }
  /*
  ip_configuration {
    name                          = azurerm_public_ip.public_ips[1].name
    public_ip_address_id          = azurerm_public_ip.public_ips[1].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gw_subnet.id
  }
  */
}


resource "azurerm_public_ip" "vm_public_ip" {
  name                = "publicIpVm1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "intf1" {
  name                = "intf1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet[0].id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_virtual_machine" "host" {
  name                          = "host-vm1"
  location                      = var.rg_location
  resource_group_name           = var.rg_name
  network_interface_ids         = [azurerm_network_interface.intf1.id]
  vm_size                       = "Standard_D1_v2"
  delete_os_disk_on_termination = true
  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04.0-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "multicloudhost1vm1disk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "multicloud-azurevm1"
    admin_username = var.username
    admin_password = var.password
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}


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
