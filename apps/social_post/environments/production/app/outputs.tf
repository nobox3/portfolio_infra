output "app_id" {
  value     = local.app_id
  sensitive = true
}

output "ssm_parameter_path" {
  value     = local.ssm_parameter_path
  sensitive = true
}

output "vpc_id" {
  value     = module.network.vpc_id
  sensitive = true
}

output "target_group_arn" {
  value     = module.alb.lb_target_group_arn
  sensitive = true
}

output "app_bucket_id" {
  value     = module.app_bucket.s3_bucket_id
  sensitive = true
}

output "cdn_id" {
  value     = module.cdn.id
  sensitive = true
}
