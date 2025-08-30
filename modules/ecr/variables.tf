variable "name" {
  type = string
}

variable "force_delete" {
  type    = bool
  default = false
}

variable "holding_count" {
  type    = number
  default = 10
}
