module "mail_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 5.2.0"

  bucket        = var.mail_bucket_name
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
    Name = var.mail_bucket_name
  }
}

data "aws_iam_policy_document" "s3_bucket" {
  statement {
    sid     = "AllowSESPuts"
    actions = ["s3:PutObject"]

    principals {
      type        = "Service"
      identifiers = ["ses.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceAccount"
      values   = [data.aws_caller_identity.self.account_id]
    }

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [local.rule_arn]
    }

    resources = ["${module.mail_bucket.s3_bucket_arn}/*"]
  }
}
