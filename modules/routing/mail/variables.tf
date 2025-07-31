variable "zone_id" {
  type        = string
  description = "The Route53 zone ID for the host configuration."
}

variable "mail_service_host" {
  type        = string
  description = "The host for the mail service, e.g., 'sendgrid.net'."
}

variable "host_prefix" {
  type        = string
  default     = ""
  description = "The prefix for the host, used in DNS records."
}

variable "domain_key" {
  type        = string
  sensitive   = true
  description = "The SSM parameter key for the domain used in endpoint construction."
}

variable "name_prefix_main" {
  type        = string
  sensitive   = true
  description = "The prefix for the main domain."
}

variable "link_brand_primary" {
  type        = string
  sensitive   = true
  description = "The primary link brand used in the routing configuration."
}

variable "link_brand_secondary" {
  type        = string
  sensitive   = true
  description = "The secondary link brand used in the routing configuration."
}

variable "ttl" {
  type        = number
  default     = 3600
  description = "The TTL for DNS records."
}
