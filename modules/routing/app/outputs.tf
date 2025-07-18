output "route53_zone_id" {
  value = aws_route53_zone.this.id
}

output "acm_certificate_root_arn" {
  value = aws_acm_certificate.root.arn
}
