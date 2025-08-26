output "vpc_id" {
  value     = module.network.vpc_id
  sensitive = true
}

output "target_group_arn" {
  value     = module.alb.lb_target_group_arn
  sensitive = true
}
