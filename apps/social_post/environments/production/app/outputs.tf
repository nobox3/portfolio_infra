output "app_id" {
  value     = local.app_id
  sensitive = true
}

output "vpc_id" {
  value     = module.app.vpc_id
  sensitive = true
}

output "target_group_arn" {
  value     = module.app.target_group_arn
  sensitive = true
}
