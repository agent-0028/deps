
resource "aws_s3_bucket" "bucket" {
  bucket              = "${var.attributes.bucket}${var.env-suffix}"
  bucket_prefix       = var.attributes.bucket_prefix
  force_destroy       = false
  object_lock_enabled = false
  tags = {
    Repo        = var.repo
    Environment = var.env
  }
}

resource "aws_s3_bucket_ownership_controls" "ownership_controls" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    object_ownership = var.object_ownership
  }
}

data "aws_s3_bucket" "current_bucket" {
  bucket = aws_s3_bucket.bucket.bucket
}
