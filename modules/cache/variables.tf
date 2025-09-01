variable "app_id" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to create the cache cluster in."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to associate with the cache."
}

variable "node_type" {
  type        = string
  default     = "cache.t3.micro"
  description = "The instance type for the cache nodes."
}
