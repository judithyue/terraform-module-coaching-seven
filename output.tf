# root/outputs.tf
output "web_app_ips" {
  value = module.web_app.instance_public_ips
}

output "web_app_subnets" {
  value = module.web_app.instance_subnet_ids
}

output "instance_placement_map" {
  value = module.web_app.instance_placement_map
}