output "app_id" {
  value     = local.app_id
  sensitive = true
}

output "task_execution_role_arn" {
  value     = module.app.task_execution_role_arn
  sensitive = true
}

output "task_role_arn" {
  value     = module.app.task_role_arn
  sensitive = true
}

output "images" {
  value     = module.app.images
  sensitive = true
}

output "log_group_names" {
  value     = module.app.log_group_names
  sensitive = true
}

output "cluster_arn" {
  value     = module.app.cluster_arn
  sensitive = true
}

output "security_groups" {
  value     = module.app.security_groups
  sensitive = true
}

output "subnets" {
  value     = module.app.subnets
  sensitive = true
}

output "target_group_arn" {
  value     = module.app.target_group_arn
  sensitive = true
}
