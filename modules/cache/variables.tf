variable "app_id" {
  type = string
}

variable "node_type" {
  type        = string
  default     = "cache.t3.micro"
  description = "The instance type for the cache nodes."
}

variable "subnet_group_name" {
  type        = string
  description = "The name of the subnet group for the cache."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to associate with the cache."
}
