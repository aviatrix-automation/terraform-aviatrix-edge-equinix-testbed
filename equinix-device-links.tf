data "equinix_network_device" "aviatrix_edge" {
  count = var.create_device_links && var.update_egress_ip && var.create_aviatrix_edge ? 1 : 0
  name  = var.edge_gw_name
}

data "equinix_network_device" "iperf" {
  count = var.create_device_links && var.update_egress_ip && var.create_edge_iperf ? 1 : 0
  name  = var.iperf_gw_name
}

resource "equinix_network_device_link" "edge_wan" {
  count = var.create_device_links && var.create_aviatrix_edge ? 1 : 0

  name = "edge-wan-link"
  device {
    id           = data.equinix_network_device.aviatrix_edge[0].uuid // Edge eth0
    interface_id = 1
  }
  device {
    id           = equinix_network_device.this[0].uuid // CSR Gi9
    interface_id = 9
  }
}

resource "equinix_network_device_link" "edge_lan" {
  count = var.create_device_links && var.create_aviatrix_edge ? 1 : 0

  name = "edge-lan-link"
  device {
    id           = data.equinix_network_device.aviatrix_edge[0].uuid // Edge eth0
    interface_id = 2
  }
  device {
    id           = equinix_network_device.this[0].uuid // CSR Gi8
    interface_id = 8
  }
}

resource "equinix_network_device_link" "iperf_wan" {
  count = var.create_device_links && var.create_edge_iperf ? 1 : 0

  name = "iperf-wan-link"
  device {
    id           = data.equinix_network_device.iperf[0].uuid // Edge eth0
    interface_id = 1
  }
  device {
    id           = equinix_network_device.this[0].uuid // CSR Gi6
    interface_id = 10
  }
}