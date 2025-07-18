variable "app_id" {
  type = string
}

variable "ssm_parameter_path" {
  type        = string
  description = "The SSM parameter path to fetch environment variables from."
}

variable "app_bucket_arn" {
  type        = string
  description = "The ARN of the S3 bucket to store application artifacts."
}
