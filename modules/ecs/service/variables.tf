variable "app_id" {
  type = string
}

variable "task_execution_role_arn" {
  type        = string
  description = "The ARN of the IAM role used for ECS task execution."
}

variable "task_role_arn" {
  type        = string
  description = "The ARN of the IAM role used for ECS tasks."
}

variable "images" {
  type = object({
    web : string
    nginx : string
  })

  description = "Map of image URLs for the ECS containers. The keys should match the container names defined in the task definition."
}

variable "log_group_names" {
  type = object({
    web : string
    nginx : string
  })

  description = "Map of log group names for the ECS containers. The keys should match the container names defined in the task definition."
}

variable "desired_count" {
  type        = number
  default     = 1
  description = "The desired number of instances of the service to run."
}

variable "cluster_arn" {
  type        = string
  description = "The ARN of the ECS cluster where the service will be deployed."
}

variable "security_groups" {
  type        = list(string)
  description = "A list of security group IDs to associate with the ECS service."
}

variable "subnets" {
  type        = list(string)
  description = "A list of subnet IDs where the ECS service will be deployed."
}

variable "target_group_arn" {
  type        = string
  description = "The ARN of the target group to register the ECS service with."
}

variable "deployer_role_id" {
  type        = string
  description = "The ID of the IAM role used by the deployer."
}
