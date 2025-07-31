module "this" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket        = var.bucket_name
  force_destroy = true
  attach_policy = true
  policy        = data.aws_iam_policy_document.s3_bucket.json

  server_side_encryption_configuration = {
    rule = {
      apply_server_side_encryption_by_default = {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = {
    Name = var.bucket_name
  }
}

data "aws_iam_policy_document" "s3_bucket" {
  statement {
    sid     = "AllowECSTaskS3Access"
    actions = ["s3:ListBucket", "s3:PutObject", "s3:GetObject", "s3:DeleteObject"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }

    resources = [module.this.s3_bucket_arn, "${module.this.s3_bucket_arn}/*"]
  }
}
