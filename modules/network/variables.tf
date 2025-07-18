variable "app_id" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block for the VPC."
}

variable "azs" {
  type = map(object({
    public_cidr  = string
    private_cidr = string
  }))

  default = {
    a = {
      public_cidr  = "10.0.0.0/20"
      private_cidr = "10.0.16.0/20"
    },
    c = {
      public_cidr  = "10.0.64.0/20"
      private_cidr = "10.0.80.0/20"
    }
  }

  description = "Availability zones and their corresponding public and private CIDR blocks."
}

variable "enable_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to enable NAT Gateway for the VPC."
}

variable "single_nat_gateway" {
  type        = bool
  default     = true
  description = "Whether to use a single NAT Gateway across all availability zones."
}
