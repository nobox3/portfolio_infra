data "aws_route53_zone" "host" {
  zone_id = var.zone_id
}

locals {
  domain_base   = "${var.host_prefix}${data.aws_route53_zone.host.name}"
  endpoint_base = "${var.domain_key}.${var.mail_service_host}"
}

# ----------------------------------------
# Domain Authentication
# ----------------------------------------
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = "${var.name_prefix_main}.${local.domain_base}"
  type    = "CNAME"
  ttl     = var.ttl
  records = [local.endpoint_base]
}

resource "aws_route53_record" "dkim" {
  for_each = toset(["s1", "s2"])

  zone_id = data.aws_route53_zone.host.zone_id
  name    = "${each.value}._domainkey.${local.domain_base}"
  type    = "CNAME"
  ttl     = var.ttl
  records = ["${each.value}.domainkey.${local.endpoint_base}"]
}

resource "aws_route53_record" "dmarc" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = "_dmarc.${local.domain_base}"
  type    = "TXT"
  ttl     = var.ttl
  records = ["v=DMARC1; p=none;"]
}

# ----------------------------------------
# Link Branding
# ----------------------------------------
resource "aws_route53_record" "link_brand_primary" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = "${var.link_brand_primary}.${local.domain_base}"
  type    = "CNAME"
  ttl     = var.ttl
  records = [var.mail_service_host]
}

resource "aws_route53_record" "link_brand_secondary" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = "${var.link_brand_secondary}.${local.domain_base}"
  type    = "CNAME"
  ttl     = var.ttl
  records = [var.mail_service_host]
}
