locals {
  ssm_parameter_path = "/${replace(var.app_id, "-", "/")}"
  app_bucket_name    = replace("${var.organization}-${var.app_id}-app", "_", "-")
}

data "aws_ssm_parameter" "db_name" {
  name = "${local.ssm_parameter_path}/DATABASE_NAME"
}

data "aws_ssm_parameter" "db_username" {
  name = "${local.ssm_parameter_path}/DATABASE_USERNAME"
}

data "aws_ssm_parameter" "db_password" {
  name = "${local.ssm_parameter_path}/DATABASE_PASSWORD"
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
  log_bucket_name   = replace("${var.organization}-${var.app_id}-alb-log", "_", "-")
}

# ----------------------------------------
# Database
# ----------------------------------------
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
# ECS
# ----------------------------------------
module "app_log" {
  source = "../../../../modules/log/app"

  app_id = var.app_id
}

module "app_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket = local.app_bucket_name

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = local.app_bucket_name
  }
}

module "ecs" {
  source = "../../../../modules/ecs/cluster"

  app_id             = var.app_id
  ssm_parameter_path = local.ssm_parameter_path
  app_bucket_arn     = module.app_bucket.s3_bucket_arn
}
