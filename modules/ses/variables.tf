variable "app_id" {
  type = string
}

variable "zone_id" {
  type        = string
  description = "The Route53 zone ID for the host configuration."
}

variable "rule_set_name" {
  type        = string
  default     = "primary"
  description = "The name of the SES receipt rule set."
}

variable "recipients_for_host" {
  type = list(object({
    name          = string
    domain_prefix = string
  }))

  description = "List of email recipients for the SES receipt rule."
}

variable "mail_bucket_name" {
  type        = string
  description = "The name of the S3 bucket used for SES mail storage."
}

variable "mail_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket used for SES mail storage."
}
