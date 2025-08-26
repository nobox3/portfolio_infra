variable "app_id" {
  type = string
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

variable "deployer_role_id" {
  type        = string
  description = "The ID of the IAM role used by the deployer."
}
