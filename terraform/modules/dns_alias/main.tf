variable "env" {
  type = string
}

variable "env-suffix" {
  type    = string
  default = "dev"
}

variable "name" {
  type    = string
  default = "example.com"
}

variable "zone_id" {
  type    = string
  default = ""
}

variable "alias_zone_id" {
  type    = string
  default = ""
}

variable "value" {
  type    = string
  default = ""
}

variable "evaluate_target_health" {
  type    = bool
  default = false
}
