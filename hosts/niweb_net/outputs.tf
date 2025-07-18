output "route53_zone_id" {
  value     = module.routing.route53_zone_id
  sensitive = true
}

output "acm_certificate_root_arn" {
  value     = module.routing.acm_certificate_root_arn
  sensitive = true
}
