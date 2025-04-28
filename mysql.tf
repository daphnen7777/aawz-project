resource "azurerm_network_interface" "mysql-network-interface" {
  name = "mysql-network-interface-testing"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  ip_configuration {
    name = "mysql-ip-configuration"
    subnet_id = azurerm_subnet.appdb-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.mysql-public-ip.id
  }
}

resource "azurerm_public_ip" "mysql-public-ip" {
  name = "mysql-public-ip"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_virtual_machine" "testing-mysql" {
  name = "testing_mysql"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  network_interface_ids = [ azurerm_network_interface.mysql-network-interface.id ]
  vm_size = "Standard_B1s"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  
  storage_image_reference {
    publisher = "Canonical"
    offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts"
    version = "latest"
  }
  storage_os_disk {
    name = "mysql-storage-os-disk"
    create_option = "FromImage"
    
  }
  os_profile {
    computer_name = "hostname"
    admin_username = "ubuntu"
    admin_password = "Mysql1220."
    custom_data = file("mysql.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }
}

resource "azurerm_network_security_group" "mysql-nsg" {
  name = "mysql-nsg"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  security_rule {
    name = "mysql"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "3306"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_interface_security_group_association" "mysql-sg" {
  network_interface_id      = azurerm_network_interface.mysql-network-interface.id
  network_security_group_id = azurerm_network_security_group.mysql-nsg.id
}

resource "azurerm_subnet" "bastion-subnet" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.appdb.name
  virtual_network_name = azurerm_virtual_network.appdb-network.name
  address_prefixes = [ "20.0.3.0/26" ]
}

resource "azurerm_public_ip" "bastion-ip" {
  name                = "bastion-ip"
  location            = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "appdb-network-bastion" {
  name                = "appdb-network-bastion"
  location            = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion-subnet.id
    public_ip_address_id = azurerm_public_ip.bastion-ip.id
  }
}