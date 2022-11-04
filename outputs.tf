output "router_config" {
  value = var.create_pvif && var.create_aviatrix_edge ? try(local.router_config, "") : ""
}