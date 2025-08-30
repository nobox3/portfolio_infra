data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

data "aws_ecr_image" "nginx" {
  repository_name = "${var.repository_name_prefix}-nginx"
  most_recent     = true
}

data "aws_ecr_image" "web" {
  repository_name = "${var.repository_name_prefix}-web"
  most_recent     = true
}

data "aws_route53_zone" "host" {
  zone_id = var.zone_id
}

data "aws_vpc" "app" {
  id = var.vpc_id
}

data "aws_security_groups" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name = "group-name"

    values = [
      "${data.aws_vpc.app.tags.Name}-vpc",
      "${data.aws_vpc.app.tags.Name}-db",
      "${data.aws_vpc.app.tags.Name}-cache",
    ]
  }
}

data "aws_subnets" "app" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  filter {
    name   = "tag:Name"
    values = ["${data.aws_vpc.app.tags.Name}-private-*"]
  }
}

data "aws_db_instance" "app" {
  db_instance_identifier = replace(var.app_id, "_", "-")
}

data "aws_elasticache_replication_group" "app" {
  replication_group_id = replace(var.app_id, "_", "-")
}

data "aws_s3_bucket" "app" {
  bucket = var.app_bucket_id
}

data "aws_cloudfront_distribution" "app" {
  id = var.cdn_id
}
