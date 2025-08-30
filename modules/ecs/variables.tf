variable "app_id" {
  type = string
}

variable "zone_id" {
  type        = string
  description = "The Route53 zone ID for the host configuration."
}

variable "deployer_role_id" {
  type        = string
  description = "The ID of the IAM role used by the deployer."
}

variable "repository_name_prefix" {
  type        = string
  description = "The prefix for the ECR repository names."
}

variable "ssm_parameter_path" {
  type        = string
  description = "The SSM parameter path to fetch environment variables from."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The desired number of instances of the service to run."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the ECS service will be deployed."
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the target group to register the ECS service with."
}

variable "app_bucket_id" {
  type        = string
  description = "The ID of the S3 bucket to store application artifacts."
}

variable "cdn_id" {
  type        = string
  description = "The ID of the CloudFront distribution for the CDN."
}
