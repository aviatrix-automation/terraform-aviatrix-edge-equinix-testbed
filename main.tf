data "equinix_network_account" "this" {
  metro_code = var.metro_code
}

resource "equinix_network_device" "this" {
  count = var.create_router ? 1 : 0

  metro_code      = data.equinix_network_account.this.metro_code
  account_number  = data.equinix_network_account.this.number
  type_code       = var.type_code
  byol            = true
  self_managed    = true
  core_count      = var.core_count
  package_code    = var.package_code
  version         = var.device_version
  throughput      = var.throughput
  throughput_unit = var.throughput_unit
  name            = var.router_name
  hostname        = var.router_hostname
  notifications   = var.notifications
  term_length     = var.term_length

  ssh_key {
    username = var.ssh_username
    key_name = local.ssh_key_name
  }

  acl_template_id = local.acl_template_id
}

locals {
  acl_template_id = var.create_acl ? equinix_network_acl_template.this[0].id : var.acl_template_id
  ssh_key_name    = var.create_ssh_key ? equinix_network_ssh_key.this[0].name : var.ssh_key_name

  router_interface_config = <<EOT
    !
    vrf definition WAN
    rd ${try(var.router_wan_asn, "")}:1
     !
     address-family ipv4
     exit-address-family
    !
    vrf definition LAN
     rd ${try(var.router_lan_asn, "")}:2
     !
     address-family ipv4
     exit-address-family
    !
    interface GigabitEthernet9
     description "EDGE-WAN-NETWORK"
     vrf forwarding WAN
     ip address ${try(var.edge_wan_gw, "")} ${try(cidrnetmask(var.edge_wan_ip), "")}
     no shut
    exit
    !
    interface GigabitEthernet8
     description "EDGE-LAN-NETWORK"
     vrf forwarding LAN
     ip address ${try(cidrhost(var.edge_lan_ip, 1), "")} ${try(cidrnetmask(var.edge_lan_ip), "")}
     no shut
    exit
    !
    interface GigabitEthernet10
     description "IPERF-WAN-NETWORK"
     vrf forwarding WAN
     ip address ${try(var.iperf_wan_gw, "")} ${try(cidrnetmask(var.iperf_wan_ip), "")}
     no shut
    exit
    !
    interface Loopback100
     vrf forwarding LAN
     ip address 192.168.100.1 255.255.255.0
     no shut
    !
    router bgp ${try(var.router_asn, "")}
     bgp router-id ${try(var.edge_wan_gw, "")}
     !
     address-family ipv4 vrf LAN
      network ${try(split("/", cidrsubnet(var.loopback, 0, 0))[0], "")}
      neighbor ${try(split("/", var.edge_lan_ip)[0], "")} remote-as ${try(var.edge_asn, "")}
      neighbor ${try(split("/", var.edge_lan_ip)[0], "")} local-as ${try(var.router_lan_asn, "")}
      neighbor ${try(split("/", var.edge_lan_ip)[0], "")} activate
     exit-address-family
    end
    !
    EOT
}

