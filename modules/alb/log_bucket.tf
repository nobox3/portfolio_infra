module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket = var.log_bucket_name

  # Allow deletion of non-empty bucket
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_elb_log_delivery_policy = true # Required for ALB logs
  attach_lb_log_delivery_policy  = true # Required for ALB/NLB logs

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule = [
    {
      id     = "alb-log"
      status = "Enabled"

      filter = {
        prefix = ""
      }

      expiration = {
        days = var.log_expiration_in_days
      }
    }
  ]

  tags = {
    Name = var.log_bucket_name
  }
}
