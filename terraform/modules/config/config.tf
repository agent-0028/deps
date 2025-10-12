output "aws_region" {
  value = var.aws_region
}

output "env-prefix" {
  value = var.env == local.PROD ? "" : "${var.env}-"
}

output "env-suffix" {
  value = var.env == local.PROD ? "" : "-${var.env}"
}

output "env" {
  value = var.env
}

output "is-prod" {
  value = (var.env == local.PROD)
}

output "repo" {
  value = var.repo
}
