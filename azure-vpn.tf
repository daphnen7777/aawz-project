provider "azurerm" {
  features { }
  subscription_id = ""
}

resource "azurerm_resource_group" "appdb" {
  name = "appdb"
  location = "Korea Central"
}

resource "azurerm_virtual_network" "appdb-network" {
  name = "appdb-network"
  resource_group_name = azurerm_resource_group.appdb.name
  location = azurerm_resource_group.appdb.location
  address_space = [ "20.0.0.0/16" ]
}

resource "azurerm_subnet" "appdb-subnet" {
  name = "appdb-subnet"
  resource_group_name = azurerm_resource_group.appdb.name
  virtual_network_name = azurerm_virtual_network.appdb-network.name
  address_prefixes = [ "20.0.1.0/24" ]
}

resource "azurerm_subnet" "gateway-subnet" {
  name = "GatewaySubnet"
  resource_group_name = azurerm_resource_group.appdb.name
  virtual_network_name = azurerm_virtual_network.appdb-network.name
  address_prefixes = [ "20.0.2.0/24" ]
}

resource "azurerm_public_ip" "vpn-public-ip1" {
  name = "vpn-public-ip1"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "azurerm_public_ip" "vpn-public-ip2" {
  name = "vpn-public-ip2"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  allocation_method = "Static"
  sku = "Standard"
}

resource "time_sleep" "delay-1" {
  depends_on = [ azurerm_virtual_machine.testing-tomcat ]
  create_duration = "1m"
}

resource "azurerm_virtual_network_gateway" "vgwB" {
  name = "vgwB"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  type = "Vpn"
  sku = "VpnGw2"
  active_active = true
  enable_bgp = true
  ip_configuration {
    name = "vpn1"
    subnet_id = azurerm_subnet.gateway-subnet.id
    public_ip_address_id = azurerm_public_ip.vpn-public-ip1.id
  }
  ip_configuration {
    name = "vpn2"
    subnet_id = azurerm_subnet.gateway-subnet.id
    public_ip_address_id = azurerm_public_ip.vpn-public-ip2.id
  }
  bgp_settings {
    asn = 65515
    peering_addresses{
      ip_configuration_name = "vpn1"
      apipa_addresses = ["169.254.21.2", "169.254.22.2"]
    }
    peering_addresses{
      ip_configuration_name = "vpn2"
      apipa_addresses = ["169.254.21.6", "169.254.22.6"]
    }
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_local_network_gateway" "lgwB1" {
  name = "lgwB1"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  gateway_address = aws_vpn_connection.aws-azrm-vpn-0.tunnel1_address
  bgp_settings {
    asn = 64512
    bgp_peering_address = "169.254.21.1"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_local_network_gateway" "lgwB2" {
  name = "lgwB2"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  gateway_address = aws_vpn_connection.aws-azrm-vpn-0.tunnel2_address
  bgp_settings {
    asn = 64512
    bgp_peering_address = "169.254.22.1"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_local_network_gateway" "lgwB3" {
  name = "lgwB3"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  gateway_address = aws_vpn_connection.aws-azrm-vpn-1.tunnel1_address
  bgp_settings {
    asn = 64512
    bgp_peering_address = "169.254.21.5"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_local_network_gateway" "lgwB4" {
  name = "lgwB4"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  gateway_address = aws_vpn_connection.aws-azrm-vpn-1.tunnel2_address
  bgp_settings {
    asn = 64512
    bgp_peering_address = "169.254.22.5"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_virtual_network_gateway_connection" "vpnB1" {
  name = "azrm-aws-vpn-connection1"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vgwB.id
  local_network_gateway_id = azurerm_local_network_gateway.lgwB1.id
  shared_key = "test123456"
  enable_bgp = true
  custom_bgp_addresses {
    primary = "169.254.21.2"
    secondary = "169.254.21.6"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_virtual_network_gateway_connection" "vpnB2" {
  name = "azrm-aws-vpn-connection2"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vgwB.id
  local_network_gateway_id = azurerm_local_network_gateway.lgwB2.id
  shared_key = "test123456"
  enable_bgp = true
  custom_bgp_addresses {
    primary = "169.254.22.2"
    secondary = "169.254.22.6"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_virtual_network_gateway_connection" "vpnB3" {
  name = "azrm-aws-vpn-connection3"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vgwB.id
  local_network_gateway_id = azurerm_local_network_gateway.lgwB3.id
  shared_key = "test123456"
  enable_bgp = true
  custom_bgp_addresses {
    primary = "169.254.21.2"
    secondary = "169.254.21.6"
  }
  depends_on = [ time_sleep.delay-1 ]
}

resource "azurerm_virtual_network_gateway_connection" "vpnB4" {
  name = "azrm-aws-vpn-connection4"
  location = azurerm_resource_group.appdb.location
  resource_group_name = azurerm_resource_group.appdb.name
  type = "IPsec"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.vgwB.id
  local_network_gateway_id = azurerm_local_network_gateway.lgwB4.id
  shared_key = "test123456"
  enable_bgp = true
  custom_bgp_addresses {
    primary = "169.254.22.2"
    secondary = "169.254.22.6"
  }
  depends_on = [ time_sleep.delay-1 ]
}
