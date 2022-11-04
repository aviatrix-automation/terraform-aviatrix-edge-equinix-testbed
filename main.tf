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
}