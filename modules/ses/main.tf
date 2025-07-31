data "aws_caller_identity" "self" {}

data "aws_region" "current" {}

data "aws_route53_zone" "host" {
  zone_id = var.zone_id
}

locals {
  rule_arn = "arn:aws:ses:${data.aws_region.current.region}:${data.aws_caller_identity.self.account_id}:receipt-rule-set/${var.rule_set_name}:receipt-rule/${var.app_id}"
}

# ----------------------------------------
# MX Record
# ----------------------------------------
resource "aws_route53_record" "main" {
  zone_id = data.aws_route53_zone.host.zone_id
  name    = data.aws_route53_zone.host.name
  type    = "MX"
  ttl     = 300
  records = ["10 inbound-smtp.${data.aws_region.current.region}.amazonaws.com"]
}

# ----------------------------------------
# SNS Topic
# ----------------------------------------
resource "aws_sns_topic" "this" {
  name = "${var.app_id}-mail"

  tags = {
    Name = "${var.app_id}-mail"
  }
}

# ----------------------------------------
# Receipt Rule
# ----------------------------------------
resource "aws_ses_receipt_rule" "this" {
  name          = var.app_id
  rule_set_name = var.rule_set_name
  recipients    = [for r in var.recipients_for_host : "${r.name}@${r.domain_prefix}${data.aws_route53_zone.host.name}"]
  enabled       = true
  scan_enabled  = true

  add_header_action {
    header_name  = "Custom-Header"
    header_value = "Added by SES"
    position     = 1
  }

  s3_action {
    bucket_name  = var.mail_bucket_name
    topic_arn    = aws_sns_topic.this.arn
    iam_role_arn = aws_iam_role.ses.arn
    position     = 2
  }
}

# ----------------------------------------
# SES Assume Role
# ----------------------------------------
resource "aws_iam_role" "ses" {
  name               = "${var.app_id}-ses"
  assume_role_policy = data.aws_iam_policy_document.ses.json

  tags = {
    Name = "${var.app_id}-ses"
  }
}

data "aws_iam_policy_document" "ses" {
  statement {
    sid     = "AllowSESAssume"
    actions = ["sts:AssumeRole"]

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
  }
}

resource "aws_iam_role_policy" "ses_mail_bucket" {
  name   = "mail-bucket"
  role   = aws_iam_role.ses.id
  policy = data.aws_iam_policy_document.ses_mail_bucket.json
}

data "aws_iam_policy_document" "ses_mail_bucket" {
  statement {
    sid       = "S3Access"
    actions   = ["s3:PutObject"]
    resources = ["${module.mail_bucket.s3_bucket_arn}/*"]
  }

  statement {
    sid       = "SNSAccess"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.this.arn]
  }
}
