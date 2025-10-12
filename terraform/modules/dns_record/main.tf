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

variable "type" {
  type    = string
  default = ""
}

variable "records" {
  type    = list(any)
  default = []
}

variable "zone_id" {
  type    = string
  default = ""
}

variable "ttl" {
  type    = number
  default = 172800
}