locals {
  cdn_region = "us-east-1"
}

data "aws_route53_zone" "host" {
  zone_id = var.zone_id
}

data "aws_acm_certificate" "cdn" {
  domain = data.aws_route53_zone.host.name
  region = local.cdn_region
}

data "aws_cloudfront_cache_policy" "this" {
  name = "UseOriginCacheControlHeaders"
}

data "aws_cloudfront_origin_request_policy" "this" {
  name = "Managed-AllViewer"
}

data "aws_cloudfront_response_headers_policy" "this" {
  name = "Managed-CORS-with-preflight-and-SecurityHeadersPolicy"
}

resource "aws_cloudfront_distribution" "this" {
  enabled         = true
  is_ipv6_enabled = true
  price_class     = "PriceClass_200"

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.cdn.arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  origin {
    origin_id   = var.app_id
    domain_name = data.aws_route53_zone.host.name

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      http_port              = 80
      https_port             = 443
      origin_ssl_protocols   = ["TLSv1.2"]
    }
  }

  default_cache_behavior {
    target_origin_id       = var.app_id
    compress               = true
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    cache_policy_id            = data.aws_cloudfront_cache_policy.this.id
    origin_request_policy_id   = data.aws_cloudfront_origin_request_policy.this.id
    response_headers_policy_id = data.aws_cloudfront_response_headers_policy.this.id
  }

  tags = {
    Name = var.app_id
  }
}

resource "aws_cloudwatch_log_group" "cdn" {
  name              = "/cdn/${var.app_id}"
  region            = local.cdn_region
  retention_in_days = 90
}
