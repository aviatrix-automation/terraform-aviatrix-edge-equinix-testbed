resource "azurerm_subnet" "er_gateway" {
  count = var.create_er ? 1 : 0

  resource_group_name  = module.azure_transit[0].vpc.resource_group
  virtual_network_name = module.azure_transit[0].vpc.name
  name                 = "GatewaySubnet"
  address_prefixes     = [local.azure_ergw_subnet]

  depends_on = [module.azure_transit]
}

resource "azurerm_public_ip" "er_gateway" {
  count = var.create_er ? 1 : 0

  resource_group_name = module.azure_transit[0].vpc.resource_group
  location            = var.azure_region
  name                = "ergw-pip"
  sku                 = "Basic"
  allocation_method   = "Dynamic"
}

# Creating an ER gateway takes ~45-60 mins
resource "azurerm_virtual_network_gateway" "er_gateway" {
  count = var.create_er ? 1 : 0

  resource_group_name = module.azure_transit[0].vpc.resource_group
  location            = var.azure_region
  name                = "ergw"
  type                = "ExpressRoute"

  sku           = "Standard"
  active_active = false
  enable_bgp    = false

  ip_configuration {
    name                          = "default"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.er_gateway[0].id
    public_ip_address_id          = azurerm_public_ip.er_gateway[0].id
  }
}

resource "azurerm_express_route_circuit" "this" {
  count = var.create_er ? 1 : 0

  resource_group_name   = module.azure_transit[0].vpc.resource_group
  name                  = var.er_connection_name
  location              = var.azure_region
  service_provider_name = "Equinix"
  peering_location      = "New York"
  bandwidth_in_mbps     = 50

  sku {
    tier   = "Standard"
    family = "MeteredData"
  }

  allow_classic_operations = false
}

resource "azurerm_express_route_circuit_peering" "this" {
  count = var.create_er ? 1 : 0

  resource_group_name           = module.azure_transit[0].vpc.resource_group
  express_route_circuit_name    = azurerm_express_route_circuit.this[0].name
  peering_type                  = "AzurePrivatePeering"
  peer_asn                      = var.router_wan_asn
  primary_peer_address_prefix   = var.er_primary_address
  secondary_peer_address_prefix = var.er_secondary_address
  vlan_id                       = var.er_vlan_id
  shared_key                    = var.bgp_auth_key
}

data "equinix_ecx_l2_sellerprofile" "azure" {
  count = var.create_er ? 1 : 0
  name  = "Azure ExpressRoute"
}

resource "equinix_ecx_l2_connection" "azure" {
  count = var.create_er ? 1 : 0

  name                = var.er_connection_name
  profile_uuid        = data.equinix_ecx_l2_sellerprofile.azure[0].id
  speed               = 50
  speed_unit          = "MB"
  notifications       = var.notifications
  device_uuid         = equinix_network_device.this[0].id
  device_interface_id = 4
  seller_region       = var.azure_region
  seller_metro_code   = var.metro_code
  authorization_key   = azurerm_express_route_circuit.this[0].service_key
  named_tag           = var.er_peering_type
  zside_vlan_ctag     = var.er_vlan_id

  timeouts {
    create = "10m"
    delete = "10m"
  }

  lifecycle {
    ignore_changes = [status]
  }

  depends_on = [azurerm_express_route_circuit_peering.this]
}

resource "azurerm_virtual_network_gateway_connection" "this" {
  count = var.create_er ? 1 : 0

  name                       = "ergw-connection"
  resource_group_name        = module.azure_transit[0].vpc.resource_group
  location                   = var.azure_region
  type                       = "ExpressRoute"
  virtual_network_gateway_id = azurerm_virtual_network_gateway.er_gateway[0].id
  express_route_circuit_id   = azurerm_express_route_circuit.this[0].id
}

locals {
  azure_ergw_newbits = 27 - tonumber(split("/", var.azure_transit_cidr)[1])
  azure_ergw_netnum  = pow(2, local.azure_ergw_newbits)
  azure_ergw_subnet  = cidrsubnet(var.azure_transit_cidr, local.azure_ergw_newbits, local.azure_ergw_netnum - 2)

  router_er_config = <<EOT
    !
    interface GigabitEthernet4
     description "EXPRESS ROUTE TO TRANSIT VNET"
     vrf forwarding WAN
     ip address ${try(cidrhost(var.er_primary_address, 1), "")} ${try(cidrnetmask(var.er_primary_address), "")}
     no shut
    exit
    !
    router bgp ${try(var.router_asn, "")}
     bgp router-id ${try(var.edge_wan_gw, "")}
     !
     address-family ipv4 vrf WAN
      network ${try(split("/", cidrsubnet(var.edge_wan_ip, 0, 0))[0], "")}
      neighbor ${try(cidrhost(var.er_primary_address, 2), "")} remote-as 12076
      neighbor ${try(cidrhost(var.er_primary_address, 2), "")} password ${try(var.bgp_auth_key, "")}
      neighbor ${try(cidrhost(var.er_primary_address, 2), "")} local-as ${try(var.router_wan_asn, "")}
      neighbor ${try(cidrhost(var.er_primary_address, 2), "")} activate
     exit-address-family
     !
    EOT
}