variable "app_id" {
  type = string
}

variable "enable_alb" {
  type    = bool
  default = true
}

variable "zone_id" {
  type        = string
  description = "The ID of the Route53 zone to create the ALB in."
}

variable "security_groups" {
  type        = list(string)
  description = "A list of security group IDs to associate with the ALB."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the ALB will be deployed."
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate to use for HTTPS listeners."
}

variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the ALB will be created."
}

variable "health_check_path" {
  type        = string
  default     = "/"
  description = "The path to use for health checks on the target group."
}

variable "log_bucket_name" {
  type        = string
  description = "The name of the S3 bucket for ALB logs."
}

variable "log_expiration_in_days" {
  type    = number
  default = 90
}
