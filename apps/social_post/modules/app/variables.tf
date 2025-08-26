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

variable "enable_nat_gateway" {
  type    = bool
  default = true
}

variable "enable_alb" {
  type    = bool
  default = true
}
