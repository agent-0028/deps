
variable "repo" {
  type = string
}

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