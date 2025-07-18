output "task_execution_role_arn" {
  value     = module.ecs.task_execution_role_arn
  sensitive = true
}

output "task_role_arn" {
  value     = module.ecs.task_role_arn
  sensitive = true
}

output "images" {
  value = {
    web   = module.web.latest_image_uri
    nginx = module.nginx.latest_image_uri
  }

  sensitive = true
}

output "log_group_names" {
  value     = module.app_log.group_names
  sensitive = true
}

output "cluster_arn" {
  value     = module.ecs.cluster_arn
  sensitive = true
}

output "security_groups" {
  value = [
    module.network.security_group_ids.vpc,
    module.network.security_group_ids.db,
    module.network.security_group_ids.cache,
  ]

  sensitive = true
}

output "subnets" {
  value     = [for s in module.network.subnet.private : s.id]
  sensitive = true
}

output "target_group_arn" {
  value     = module.alb.lb_target_group_arn
  sensitive = true
}
