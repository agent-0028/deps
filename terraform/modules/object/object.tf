resource "aws_s3_object" "object" {
  bucket             = var.bucket
  bucket_key_enabled = var.bucket_key_enabled
  content_type       = var.content_type
  content            = var.content
  #   etag                   = "6aae5f83a9bb5d1d2a495f2eefcfe758"
  key                    = var.key
  metadata               = {}
  server_side_encryption = var.server_side_encryption
  storage_class          = var.storage_class
  tags = {
    Repo        = var.repo
    Environment = var.env
  }
  website_redirect = var.website_redirect
}
