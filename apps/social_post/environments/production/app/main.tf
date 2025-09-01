terraform {
  cloud {
    organization = "noboru_inoue"

    workspaces {
      name = "social_post-production"
    }
  }
}

module "config" {
  source = "../../../../../modules/config"

  workspace = "social_post-production"
}

data "tfe_outputs" "host" {
  organization = module.config.this.organization
  workspace    = "host_niweb_net"
}

locals {
  app_id             = "${module.config.this.project}-${module.config.this.workspace}"
  ssm_parameter_path = "/${replace(local.app_id, "-", "/")}"
  host_zone_id       = data.tfe_outputs.host.values.route53_zone_id
}

# ----------------------------------------
# ECR
# ----------------------------------------
module "nginx" {
  source = "../../../../../modules/ecr"

  name          = "${local.app_id}-nginx"
  holding_count = 1
  force_delete  = true
}

module "web" {
  source = "../../../../../modules/ecr"

  name          = "${local.app_id}-web"
  holding_count = 1
  force_delete  = true
}


# ----------------------------------------
# Network
# ----------------------------------------
module "network" {
  source = "../../../../../modules/network"

  enable_nat_gateway = false
  app_id             = local.app_id
}

# ----------------------------------------
# ALB
# ----------------------------------------
module "alb" {
  source = "../../../../../modules/alb"

  enable_alb = false
  app_id     = replace(module.config.this.workspace, "_", "-")
  zone_id    = local.host_zone_id

  security_groups = [
    module.network.security_group_ids.web,
    module.network.security_group_ids.vpc,
  ]

  subnets           = [for s in module.network.subnet.public : s.id]
  vpc_id            = module.network.vpc_id
  health_check_path = "/health"
  log_bucket_name   = module.alb_log_bucket.s3_bucket_id
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
  source = "../../../../../modules/db"

  app_id                 = replace(local.app_id, "_", "-")
  subnet_ids             = [for s in module.network.subnet.private : s.id]
  vpc_security_group_ids = [module.network.security_group_ids.db]
  db_name                = data.aws_ssm_parameter.db_name.value
  username               = data.aws_ssm_parameter.db_username.value
  password               = data.aws_ssm_parameter.db_password.value
}

# ----------------------------------------
# Cache
# ----------------------------------------
module "cache" {
  source = "../../../../../modules/cache"

  app_id             = replace(local.app_id, "_", "-")
  subnet_ids         = [for s in module.network.subnet.private : s.id]
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
  source = "../../../../../modules/routing/mail"

  zone_id              = local.host_zone_id
  mail_service_host    = "sendgrid.net"
  domain_key           = data.aws_ssm_parameter.domain_auth_domain_key.value
  name_prefix_main     = data.aws_ssm_parameter.domain_auth_prefix_main.value
  link_brand_primary   = data.aws_ssm_parameter.link_brand_primary.value
  link_brand_secondary = data.aws_ssm_parameter.link_brand_secondary1.value
}

module "ses" {
  source = "../../../../../modules/ses"

  app_id              = local.app_id
  zone_id             = local.host_zone_id
  recipients_for_host = [{ name = "support", domain_prefix = "" }]
  mail_bucket_name    = module.mail_bucket.s3_bucket_id
  mail_bucket_arn     = module.mail_bucket.s3_bucket_arn
}

# ----------------------------------------
# CDN
# ----------------------------------------
module "cdn" {
  source = "../../../../../modules/cdn"

  app_id  = local.app_id
  zone_id = local.host_zone_id
}
