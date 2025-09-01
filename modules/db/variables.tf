variable "app_id" {
  type = string
}

variable "subnet_ids" {
  type        = list(string)
  description = "A list of subnet IDs to create the RDS instance in."
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "A list of VPC security group IDs to associate with the database."
}

variable "db_name" {
  type        = string
  sensitive   = true
  description = "The name of the database to be created."
}

variable "username" {
  type        = string
  sensitive   = true
  description = "The username for the database."
}

variable "password" {
  type        = string
  sensitive   = true
  description = "The password for the database."
}

variable "instance_class" {
  type        = string
  default     = "db.t4g.micro"
  description = "The instance class for the RDS instance."
}

variable "allocated_storage" {
  type        = number
  default     = 20
  description = "The allocated storage size in GB for the RDS instance."
}
