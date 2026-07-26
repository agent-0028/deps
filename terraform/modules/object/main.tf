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

variable "bucket" {
  type = string
}

variable "bucket_key_enabled" {
  type    = bool
  default = false
}

variable "content_type" {
  type = string
}

variable "content" {
  type = string
}

variable "key" {
  type = string
}

variable "server_side_encryption" {
  type    = string
  default = "AES256"
}

variable "storage_class" {
  type    = string
  default = "STANDARD"
}

variable "website_redirect" {
  type    = string
  default = null
}

# etag                   = "6aae5f83a9bb5d1d2a495f2eefcfe758"
# metadata               = {}
