
variable "attributes" {
  type = object({
    bucket        = string,
    bucket_prefix = optional(string),
  })
}

variable "object_ownership" {
  type    = string
  default = "BucketOwnerPreferred"
}

variable "repo" {
  type = string
}

variable "env" {
  type = string
}

variable "env-suffix" {
  type = string
}

output "current_bucket" {
  value = data.aws_s3_bucket.current_bucket.bucket
}
