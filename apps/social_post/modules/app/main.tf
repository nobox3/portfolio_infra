locals {
  ssm_parameter_path = "/${replace(var.app_id, "-", "/")}"
  bucket_name_prefix = replace("${var.organization}-${var.app_id}", "_", "-")
}

# ----------------------------------------
# ECR
# ----------------------------------------
module "nginx" {
  source = "../../../../modules/ecr"

  name          = "${var.app_id}-nginx"
  holding_count = 1
}

module "web" {
  source = "../../../../modules/ecr"

  name          = "${var.app_id}-web"
  holding_count = 1
}

# ----------------------------------------
# Network
# ----------------------------------------
module "network" {
  source = "../../../../modules/network"

  app_id             = var.app_id
  enable_nat_gateway = var.enable_nat_gateway
}

# ----------------------------------------
# ALB
# ----------------------------------------
module "alb" {
  source = "../../../../modules/alb"

  enable_alb = var.enable_alb
  app_id     = replace(var.workspace, "_", "-")
  zone_id    = var.host_zone_id

  security_groups = [
    module.network.security_group_ids.web,
    module.network.security_group_ids.vpc,
  ]

  subnets           = [for s in module.network.subnet.public : s.id]
  certificate_arn   = var.certificate_arn
  vpc_id            = module.network.vpc_id
  health_check_path = "/health"
  log_bucket_name   = "${local.bucket_name_prefix}-alb-log"
}

# ----------------------------------------
# Database
# ----------------------------------------
data "aws_ssm_parameter" "db_name" {
  name = "${local.ssm_parameter_path}/DATABASE_NAME"
}

data "aws_ssm_parameter" "db_username" {
  name = "${local.ssm_parameter_path}/DATABASE_USERNAME"
}

data "aws_ssm_parameter" "db_password" {
  name = "${local.ssm_parameter_path}/DATABASE_PASSWORD"
}

module "db" {
  source = "../../../../modules/db"

  app_id = replace(var.app_id, "_", "-")

  db_name                = data.aws_ssm_parameter.db_name.value
  username               = data.aws_ssm_parameter.db_username.value
  password               = data.aws_ssm_parameter.db_password.value
  db_subnet_group_name   = module.network.db_subnet_group_id
  vpc_security_group_ids = [module.network.security_group_ids.db]
}

# ----------------------------------------
# Cache
# ----------------------------------------
module "cache" {
  source = "../../../../modules/cache"

  app_id             = replace(var.app_id, "_", "-")
  subnet_group_name  = module.network.elasticache_subnet_group_id
  security_group_ids = [module.network.security_group_ids.cache]
}

# ----------------------------------------
# Mail
# ----------------------------------------
data "aws_ssm_parameter" "domain_auth_domain_key" {
  name = "${local.ssm_parameter_path}/sender_auth/domain_auth/DOMAIN_KEY"
}

data "aws_ssm_parameter" "domain_auth_prefix_main" {
  name = "${local.ssm_parameter_path}/sender_auth/domain_auth/PREFIX_MAIN"
}

data "aws_ssm_parameter" "link_brand_primary" {
  name = "${local.ssm_parameter_path}/sender_auth/link_brands/PRIMARY"
}

data "aws_ssm_parameter" "link_brand_secondary1" {
  name = "${local.ssm_parameter_path}/sender_auth/link_brands/SECONDARY1"
}

module "mail" {
  source = "../../../../modules/routing/mail"

  zone_id              = var.host_zone_id
  mail_service_host    = "sendgrid.net"
  domain_key           = data.aws_ssm_parameter.domain_auth_domain_key.value
  name_prefix_main     = data.aws_ssm_parameter.domain_auth_prefix_main.value
  link_brand_primary   = data.aws_ssm_parameter.link_brand_primary.value
  link_brand_secondary = data.aws_ssm_parameter.link_brand_secondary1.value
}

module "ses" {
  source = "../../../../modules/ses"

  app_id              = var.app_id
  zone_id             = var.host_zone_id
  recipients_for_host = [{ name = "support", domain_prefix = "" }]
  mail_bucket_name    = "${local.bucket_name_prefix}-mail"
}

# ----------------------------------------
# ECS
# ----------------------------------------
module "app_log" {
  source = "../../../../modules/log/app"

  app_id = var.app_id
}

module "app_bucket" {
  source = "../../../../modules/bucket/app"

  bucket_name = "${local.bucket_name_prefix}-app"
}

module "ecs" {
  source = "../../../../modules/ecs/cluster"

  app_id             = var.app_id
  ssm_parameter_path = local.ssm_parameter_path
  app_bucket_arn     = module.app_bucket.arn
}
