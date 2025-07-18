variable "organization" {
  type = string
}

variable "workspace" {
  type = string
}

variable "app_id" {
  type = string
}

variable "host_zone_id" {
  type        = string
  description = "The Route53 zone ID for the host configuration."
}

variable "certificate_arn" {
  type        = string
  description = "The ARN of the ACM certificate for the application."
}

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_alb" {
  type    = bool
  default = true
}
