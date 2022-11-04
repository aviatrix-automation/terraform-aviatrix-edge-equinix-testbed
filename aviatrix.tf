module "transit" {
  count = var.create_transit ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-transit/aviatrix"
  version = "2.3.1"

  cloud                  = "aws"
  name                   = "aws-useast1-transit"
  region                 = var.region
  cidr                   = "10.1.0.0/23"
  account                = "aws-account"
  instance_size          = "t3.micro"
  ha_gw                  = false
  enable_transit_firenet = false
  local_as_number        = var.transit_asn
}

module "spoke" {
  count = var.create_spoke ? 1 : 0

  source  = "terraform-aviatrix-modules/mc-spoke/aviatrix"
  version = "1.4.1"

  cloud         = "AWS"
  name          = "aws-useast1-spoke1"
  cidr          = "10.1.2.0/24"
  region        = var.region
  account       = "aws-account"
  instance_size = "t3.micro"
  transit_gw    = try(module.transit[0].transit_gateway.gw_name, "")
  ha_gw         = false

  depends_on = [module.transit]
}

resource "aviatrix_edge_spoke" "edge" {
  count = var.create_aviatrix_edge ? 1 : 0

  gw_name                        = var.edge_gw_name
  site_id                        = var.edge_site_id
  management_interface_config    = var.management_interface_config
  management_interface_ip_prefix = var.management_ip
  management_default_gateway_ip  = var.management_gw
  wan_interface_ip_prefix        = var.edge_wan_ip
  wan_default_gateway_ip         = var.edge_wan_gw
  lan_interface_ip_prefix        = var.edge_lan_ip
  dns_server_ip                  = var.dns_server_ip
  secondary_dns_server_ip        = var.secondary_dns_server_ip
  ztp_file_type                  = var.ztp_file_type
  ztp_file_download_path         = var.ztp_file_download_path
  local_as_number                = var.edge_asn
  management_egress_ip_prefix    = var.update_egress_ip ? "${data.equinix_network_device.aviatrix_edge[0].ssh_ip_address}/32" : null
}

resource "time_sleep" "edge" {
  count = var.update_cloud_init ? 1 : 0

  create_duration = "3s" // wait for cloud-init.txt download to complete
  depends_on      = [aviatrix_edge_spoke.edge]
}

resource "null_resource" "edge_copy" {
  count = var.backup_cloud_init ? 1 : 0

  provisioner "local-exec" {
    command     = "cp ${path.cwd}/${local.edge_cloud_init} ${path.cwd}/${local.edge_cloud_init}.original"
    interpreter = ["bash", "-c"]
  }

  depends_on = [time_sleep.edge]
}

resource "null_resource" "edge_update" {
  count = var.update_cloud_init ? 1 : 0

  provisioner "local-exec" {
    command     = "${path.module}/update-cloud-init.sh ${path.cwd}/${local.edge_cloud_init}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.edge_copy]
}


resource "aviatrix_edge_spoke" "iperf" {
  count = var.create_edge_iperf ? 1 : 0

  gw_name                        = var.iperf_gw_name
  site_id                        = var.iperf_site_id
  management_interface_config    = var.management_interface_config
  management_interface_ip_prefix = var.management_ip
  management_default_gateway_ip  = var.management_gw
  wan_interface_ip_prefix        = var.iperf_wan_ip
  wan_default_gateway_ip         = var.iperf_wan_gw
  lan_interface_ip_prefix        = var.iperf_lan_ip
  dns_server_ip                  = var.dns_server_ip
  secondary_dns_server_ip        = var.secondary_dns_server_ip
  ztp_file_type                  = var.ztp_file_type
  ztp_file_download_path         = var.ztp_file_download_path
  management_egress_ip_prefix    = var.update_egress_ip ? "${data.equinix_network_device.iperf[0].ssh_ip_address}/32" : null
}

resource "time_sleep" "iperf" {
  count = var.update_cloud_init ? 1 : 0

  create_duration = "3s" // wait for cloud-init.txt download to complete
  depends_on      = [aviatrix_edge_spoke.iperf]
}

resource "null_resource" "iperf_copy" {
  count = var.backup_cloud_init ? 1 : 0

  provisioner "local-exec" {
    command     = "cp ${path.cwd}/${local.iperf_cloud_init} ${path.cwd}/${local.iperf_cloud_init}.original"
    interpreter = ["bash", "-c"]
  }

  depends_on = [time_sleep.iperf]
}

resource "null_resource" "iperf_update" {
  count = var.update_cloud_init ? 1 : 0

  provisioner "local-exec" {
    command     = "${path.module}/update-cloud-init.sh ${path.cwd}/${local.iperf_cloud_init}"
    interpreter = ["bash", "-c"]
  }

  depends_on = [null_resource.iperf_copy]
}

locals {
  edge_cloud_init  = "${var.edge_gw_name}-${var.edge_site_id}-cloud-init.txt"
  iperf_cloud_init = "${var.iperf_gw_name}-${var.iperf_site_id}-cloud-init.txt"
}