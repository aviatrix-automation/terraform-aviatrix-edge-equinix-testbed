variable "create_router" {
  description = "Set to true to create router in Equinix Fabric."
  type        = bool
  default     = true
}

variable "create_dx" {
  description = "Set to true to create AWS DX."
  type        = bool
  default     = true
}

variable "create_er" {
  description = "Set to true to create Azure ER."
  type        = bool
  default     = true
}

variable "accept_dx" {
  description = "Set to true to accept AWS DX connection."
  type        = bool
  default     = true
}

variable "create_pvif" {
  description = "Set to true to create AWS private VIF."
  type        = bool
  default     = true
}

variable "create_aws_transit" {
  description = "Set to true to create Aviatrix Transit."
  type        = bool
  default     = true
}

variable "create_aws_spoke" {
  description = "Set to true to create Aviatrix Spoke."
  type        = bool
  default     = true
}

variable "create_azure_transit" {
  description = "Set to true to create Aviatrix Transit."
  type        = bool
  default     = true
}

variable "create_azure_spoke" {
  description = "Set to true to create Aviatrix Spoke."
  type        = bool
  default     = true
}

variable "create_aviatrix_edge" {
  description = "Set to true to create Aviatrix Edge."
  type        = bool
  default     = true
}

variable "create_edge_iperf" {
  description = "Set to true to create Aviatrix Edge for iperf."
  type        = bool
  default     = false
}

variable "attach_edge_aws" {
  description = "Set to true to attach Edge to AWS."
  type        = bool
  default     = false
}

variable "attach_edge_azure" {
  description = "Set to true to attach Edge to Azure."
  type        = bool
  default     = false
}

variable "create_transit_peering" {
  description = "Set to true to create AWS-Azure transit peering."
  type        = bool
  default     = false
}

variable "create_edge_bgpolan" {
  description = "Set to true to create Edge BGPoLAN to LAN router."
  type        = bool
  default     = false
}

variable "create_vgw" {
  description = "Set to true to create AWS VGW and attach to Transit."
  type        = bool
  default     = true
}

variable "attach_vgw" {
  description = "Set to true to create attach VGW to Transit VPC."
  type        = bool
  default     = true
}

variable "create_device_links" {
  description = "Set to true to create Equinix device linking."
  type        = bool
  default     = false
}

variable "update_egress_ip" {
  description = "Set to true to update Edge Management Egress IP."
  type        = bool
  default     = false
}

variable "create_acl" {
  description = "Set to true to create a new Equinix Fabric ACL."
  type        = bool
  default     = false
}

variable "create_ssh_key" {
  description = "Set to true to create a new key."
  type        = bool
  default     = false
}

variable "acl_template_id" {
  description = "Existing ACL template ID."
  type        = string
  default     = null
}

variable "acl_name" {
  description = "ACL name."
  type        = string
  default     = "my-access-list"
}

variable "acl_description" {
  description = "ACL description."
  type        = string
  default     = "ACL description."
}

variable "ssh_username" {
  description = "SSH username."
  type        = string
  default     = "aviatrix"
}

variable "ssh_key_name" {
  description = "SSH key name."
  type        = string
  default     = "mykey"
}

variable "ssh_public_key" {
  description = "SSH public key."
  type        = string
  default     = null
}

variable "type_code" {
  description = "Vendor package code."
  type        = string
  default     = "CSR1000V"
}

variable "core_count" {
  description = "Number of CPU cores used by device."
  type        = number
  default     = 2
}

variable "package_code" {
  description = "Software package code."
  type        = string
  default     = "IPBASE"
}

variable "device_version" {
  description = "Vendor software version."
  type        = string
  default     = "17.03.03"
}

variable "throughput" {
  description = "License throughput."
  type        = number
  default     = 500
}

variable "throughput_unit" {
  description = "License throughput unit."
  type        = string
  default     = "Mbps"
}

variable "notifications" {
  description = "List of email addresses that will receive device status notifications."
  type        = list(string)
  default     = ["email@aviatrix.com"]
}

variable "term_length" {
  description = "Device term length in months."
  type        = number
  default     = 1
}

variable "router_name" {
  description = "CSR WAN router device_name and device_hostname."
  type        = string
  default     = "router"
}

variable "router_hostname" {
  description = "Equinix Network device hostname."
  type        = string
  default     = "router"
}

variable "aws_account_id" {
  description = "AWS account ID."
  type        = string
  default     = null
}

variable "dx_connection_name" {
  description = "SSH username."
  type        = string
  default     = "router-to-aws"
}

variable "aws_region" {
  description = "AWS region."
  type        = string
  default     = "us-east-1"
}

variable "azure_region" {
  description = "Azure region."
  type        = string
  default     = "East US"
}

variable "er_connection_name" {
  description = "SSH username."
  type        = string
  default     = "router-to-azure"
}

variable "metro_code" {
  description = "Equinix Metro location code."
  type        = string
  default     = "NY"
}

variable "pvif_name" {
  description = "AWS Private VIF name."
  type        = string
  default     = "pvif-router-equinix"
}

variable "bgp_auth_key" {
  description = "BGP authentication key."
  type        = string
  default     = "Aviatrix123#"
}

variable "vpn_gateway_id" {
  description = "Existing VPN gateway id."
  type        = string
  default     = null
}

variable "vgw_asn" {
  description = "AWS VPN Gateway BGP ASN."
  type        = number
  default     = 65000
}

variable "router_asn" {
  description = "Router BGP ASN."
  type        = number
  default     = 65001
}

variable "router_wan_asn" {
  description = "VRF WAN Router BGP ASN."
  type        = number
  default     = 65002
}

variable "router_lan_asn" {
  description = "VRF WAN Router BGP ASN."
  type        = number
  default     = 65003
}

variable "aws_transit_asn" {
  description = "Aviatrix Transit Gateway BGP ASN."
  type        = number
  default     = 65101
}

variable "azure_transit_asn" {
  description = "Aviatrix Transit Gateway BGP ASN."
  type        = number
  default     = 65102
}

variable "edge_asn" {
  description = "BGP AS Number to assign to Edge as a Spoke."
  type        = number
  default     = 65201
}

variable "backup_cloud_init" {
  description = "Set to true to backup cloud-init."
  type        = bool
  default     = true
}

variable "update_cloud_init" {
  description = "Set to true to update cloud-init."
  type        = bool
  default     = true
}

variable "ztp_file_type" {
  description = "ZTP file type."
  type        = string
  default     = "cloud-init"
}

variable "ztp_file_download_path" {
  description = "The folder path where the ZTP file will be downloaded."
  type        = string
  default     = "."
}

variable "management_interface_config" {
  description = "Management interface config type."
  type        = string
  default     = "Static"
}

variable "management_ip" {
  description = "Dummy management interface CIDR. This will be replaced by cloud-init."
  type        = string
  default     = "192.168.10.11/24"
}

variable "management_gw" {
  description = "Dummy management default gateway IP. This will be replaced by cloud-init."
  type        = string
  default     = "192.168.10.1"
}

variable "dns_server_ip" {
  description = "Primary DNS server IP."
  type        = string
  default     = "8.8.8.8"
}

variable "secondary_dns_server_ip" {
  description = "Primary DNS server IP."
  type        = string
  default     = "8.8.4.4"
}

variable "edge_gw_name" {
  description = "Edge gateway name."
  type        = string
  default     = "edge-equinix"
}

variable "edge_site_id" {
  description = "Site ID."
  type        = string
  default     = "Equinix"
}

variable "edge_wan_ip" {
  description = "WAN interface CIDR."
  type        = string
  default     = "192.168.11.11/24"
}

variable "edge_wan_gw" {
  description = "WAN default gateway IP."
  type        = string
  default     = "192.168.11.1"
}

variable "edge_lan_ip" {
  description = "LAN interface CIDR."
  type        = string
  default     = "192.168.12.11/24"
}

variable "iperf_gw_name" {
  description = "Edge gateway name for iperf."
  type        = string
  default     = "iperf-equinix"
}

variable "iperf_site_id" {
  description = "Site ID."
  type        = string
  default     = "iperf"
}

variable "iperf_wan_ip" {
  description = "WAN interface CIDR."
  type        = string
  default     = "192.168.13.12/24"
}

variable "iperf_wan_gw" {
  description = "WAN default gateway IP."
  type        = string
  default     = "192.168.13.1"
}

variable "iperf_lan_ip" {
  description = "LAN interface CIDR."
  type        = string
  default     = "192.168.14.12/24"
}

variable "loopback" {
  description = "Loopback interface CIDR."
  type        = string
  default     = "192.168.100.1/24"
}

variable "er_primary_address" {
  type        = string
  description = <<EOF
  A /30 subnet for the primary link. First usable IP address of the subnet should be assigned on the peered CE/PE-MSEE
  (Network Edge device or customer router). Microsoft will choose the second usable IP address of the subnet for the
  MSEE interface (cloud router).
  EOF
  default     = "169.254.255.252/30" // Usable IPs 169.254.255.253 - 169.254.255.254	
}

variable "er_secondary_address" {
  type        = string
  description = <<EOF
  A /30 subnet for the secondary link. First usable IP address of the subnet should be assigned on the peered
  CE/PE-MSEE (Network Edge device or customer router). Microsoft will choose the second usable IP address of the subnet
  for the MSEE interface (cloud router).
  EOF
  default     = "169.254.255.248/30" // Usable IPs 169.254.255.249 - 169.254.255.250	
}

variable "er_vlan_id" {
  type        = number
  description = "A valid VLAN ID to establish this peering on."
  default     = 500
}

variable "er_peering_type" {
  type        = string
  description = <<EOF
  The type of peering to set up in case when connecting to Azure Express Route. One of 'PRIVATE',
  'MICROSOFT'.
  EOF
  default     = "PRIVATE"

  validation {
    condition     = (contains(["PRIVATE", "MICROSOFT"], var.er_peering_type))
    error_message = "Valid values are (PRIVATE, MICROSOFT)."
  }
}

variable "azure_transit_cidr" {
  type        = string
  description = "Azure Transit VNet CIDR"
  default     = "10.2.1.0/23"
}