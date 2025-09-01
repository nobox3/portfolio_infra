locals {
  bucket_name_prefix = replace("${module.config.this.organization}-${local.app_id}", "_", "-")

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }
}

# ----------------------------------------
# ALB Log Bucket
# ----------------------------------------
module "alb_log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket        = "${local.bucket_name_prefix}-alb-log"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  server_side_encryption_configuration = local.server_side_encryption_configuration

  lifecycle_rule = [
    {
      id     = "alb-log"
      status = "Enabled"

      filter = {
        prefix = ""
      }

      expiration = {
        days = 90
      }
    }
  ]

  tags = {
    Name = "${local.bucket_name_prefix}-alb-log"
  }
}

# ----------------------------------------
# App Bucket
# ----------------------------------------
module "app_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket        = "${local.bucket_name_prefix}-app"
  force_destroy = true

  server_side_encryption_configuration = local.server_side_encryption_configuration

  tags = {
    Name = "${local.bucket_name_prefix}-app"
  }
}

data "aws_iam_policy_document" "app_bucket" {
  statement {
    sid     = "AllowECSTaskS3Access"
    actions = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    resources = [module.app_bucket.s3_bucket_arn, "${module.app_bucket.s3_bucket_arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "app_bucket_policy" {
  bucket = module.app_bucket.s3_bucket_id
  policy = data.aws_iam_policy_document.app_bucket.json
}

# ----------------------------------------
# Mail Bucket
# ----------------------------------------
module "mail_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket        = "${local.bucket_name_prefix}-mail"
  force_destroy = true

  server_side_encryption_configuration = local.server_side_encryption_configuration

  tags = {
    Name = "${local.bucket_name_prefix}-mail"
  }
}
