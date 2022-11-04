
data "equinix_ecx_l2_sellerprofile" "this" {
  name = "AWS Direct Connect"
}

data "aws_caller_identity" "current" {}

resource "equinix_ecx_l2_connection" "this" {
  count = var.create_dx ? 1 : 0

  name                = var.dx_connection_name
  profile_uuid        = data.equinix_ecx_l2_sellerprofile.this.id
  speed               = 50
  speed_unit          = "MB"
  notifications       = var.notifications
  device_uuid         = equinix_network_device.this[0].id
  device_interface_id = 3
  seller_region       = var.region
  seller_metro_code   = var.metro_code
  authorization_key   = var.aws_account_id != null ? var.aws_account_id : data.aws_caller_identity.current.account_id

  timeouts {
    create = "10m"
    delete = "10m"
  }

  lifecycle {
    ignore_changes = [status]
  }
}

# if resource creation failed due to 10 mins timed out (which is most likely), set variable `accept_dx = false` then run a `terraform apply` again
# https://github.com/hashicorp/terraform-provider-aws/issues/26335
# https://github.com/hashicorp/terraform-provider-aws/pull/27584
resource "aws_dx_connection_confirmation" "this" {
  count         = var.accept_dx ? 1 : 0
  connection_id = one([for action_data in one(equinix_ecx_l2_connection.this[0].actions).required_data : action_data["value"] if action_data["key"] == "awsConnectionId"])
}

# use data source if connection status is accepted
data "aws_dx_connection" "this" {
  count = var.accept_dx == false ? 1 : 0
  name  = equinix_ecx_l2_connection.this[0].name
}

resource "aws_vpn_gateway" "this" {
  count = var.create_vgw ? 1 : 0

  amazon_side_asn = var.vgw_asn

  tags = {
    Name = "ny-vgw"
  }
}

resource "aws_vpn_gateway_attachment" "this" {
  count = var.attach_vgw ? 1 : 0

  vpc_id         = var.attach_vgw ? module.transit[0].vpc.vpc_id : null
  vpn_gateway_id = aws_vpn_gateway.this[0].id
}

resource "aws_dx_private_virtual_interface" "this" {
  count = var.create_pvif ? 1 : 0

  connection_id  = var.accept_dx ? aws_dx_connection_confirmation.this[0].id : data.aws_dx_connection.this[0].id
  name           = var.pvif_name
  vlan           = equinix_ecx_l2_connection.this[0].zside_vlan_stag
  address_family = "ipv4"
  bgp_asn        = var.router_wan_asn
  bgp_auth_key   = var.bgp_auth_key
  vpn_gateway_id = var.create_vgw ? aws_vpn_gateway.this[0].id : var.vpn_gateway_id

  timeouts {
    create = "20m"
    delete = "20m"
  }
}

data "aws_dx_router_configuration" "this" {
  count = var.create_pvif ? 1 : 0

  virtual_interface_id   = aws_dx_private_virtual_interface.this[0].id
  router_type_identifier = "CiscoSystemsInc-2900SeriesRouters-IOS124"
}

locals {
  router_config = <<EOT
    !
    vrf definition WAN
    rd ${var.router_asn + 1}:1
     !
     address-family ipv4
     exit-address-family
    !
    vrf definition LAN
     rd ${var.router_asn + 2}:2
     !
     address-family ipv4
     exit-address-family
    !
    interface GigabitEthernet3
     description "Direct Connect to your Amazon VPC or AWS Cloud"
     vrf forwarding WAN
     ip address ${try(split("/", aws_dx_private_virtual_interface.this[0].customer_address)[0], "")} ${try(cidrnetmask(aws_dx_private_virtual_interface.this[0].customer_address), "")}
     no shut
    exit
    !
    interface GigabitEthernet4
     description "EDGE-WAN-NETWORK"
     vrf forwarding WAN
     ip address ${try(var.edge_wan_gw, "")} ${try(cidrnetmask(var.edge_wan_ip), "")}
     no shut
    exit
    !
    interface GigabitEthernet5
     description "EDGE-LAN-NETWORK"
     vrf forwarding LAN
     ip address ${try(cidrhost(var.edge_lan_ip, 1), "")} ${try(cidrnetmask(var.edge_lan_ip), "")}
     no shut
    exit
    !
    interface GigabitEthernet6
     description "IPERF-WAN-NETWORK"
     vrf forwarding WAN
     ip address ${try(var.iperf_wan_gw, "")} ${try(cidrnetmask(var.iperf_wan_ip), "")}
     no shut
    exit
    !
    interface Loopback100
     vrf forwarding LAN
     ip address 192.168.100.1 255.255.255.255
     no shut
    !
    router bgp ${var.router_asn}
     bgp router-id ${var.edge_wan_gw}
     !
     address-family ipv4 vrf WAN
      network ${split("/",cidrsubnet(var.edge_wan_ip,0,0))[0]}
      neighbor ${try(split("/", aws_dx_private_virtual_interface.this[0].amazon_address)[0], "")} remote-as ${var.vgw_asn}
      neighbor ${try(split("/", aws_dx_private_virtual_interface.this[0].amazon_address)[0], "")} password ${var.bgp_auth_key}
      neighbor ${try(split("/", aws_dx_private_virtual_interface.this[0].amazon_address)[0], "")} local-as ${var.router_wan_asn}
      neighbor ${try(split("/", aws_dx_private_virtual_interface.this[0].amazon_address)[0], "")} activate
     exit-address-family
     !
     address-family ipv4 vrf LAN
      network ${split("/",cidrsubnet(var.edge_lan_ip,0,0))[0]}
      neighbor ${split("/",var.edge_lan_ip)[0]} remote-as ${var.edge_asn}
      neighbor ${split("/",var.edge_lan_ip)[0]} local-as ${var.router_lan_asn}
      neighbor ${split("/",var.edge_lan_ip)[0]} activate
     exit-address-family
    end
    !
    EOT
}