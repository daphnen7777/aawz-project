resource "time_sleep" "delay" {
  depends_on = [ azurerm_virtual_machine.testing-mysql ]
  create_duration = "1m"
}

resource "azurerm_network_interface" "Tomcat-network-interface" {
  name = "Tomcat-network-interface-testing"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  ip_configuration {
    name = "Tomcat-ip-configuration"
    subnet_id = azurerm_subnet.appdb-subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.Tomcat-public-ip.id
  }
  depends_on = [ time_sleep.delay ]
}

resource "azurerm_public_ip" "Tomcat-public-ip" {
  name = "Tomcat-public-ip"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  allocation_method = "Static"
  sku = "Standard"
  depends_on = [ time_sleep.delay ]
}

resource "azurerm_virtual_machine" "testing-tomcat" {
  name = "testing_tomcat"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  network_interface_ids = [ azurerm_network_interface.Tomcat-network-interface.id ]
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
    name = "Tomcat-storage-os-disk"
    create_option = "FromImage"
    
  }
  os_profile {
    computer_name = "hostname"
    admin_username = "ubuntu"
    admin_password = "Tomcat1220."
    custom_data = file("tomcat.sh")
  }
  os_profile_linux_config {
    disable_password_authentication = false
  }

  depends_on = [ time_sleep.delay ]
}

resource "azurerm_network_security_group" "tomcat-nsg" {
  name = "tomcat-nsg"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  security_rule {
    name = "tomcat"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = "8080"
    source_address_prefix = "*"
    destination_address_prefix = "*"
  }
  depends_on = [ time_sleep.delay ]
}

resource "azurerm_network_interface_security_group_association" "tomcat-sg" {
  network_interface_id      = azurerm_network_interface.Tomcat-network-interface.id
  network_security_group_id = azurerm_network_security_group.tomcat-nsg.id
  depends_on = [ time_sleep.delay ]
}