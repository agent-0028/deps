locals {
  name_parts = split(".", var.name)

  env_qualified_name = (
    var.env-suffix != "" && length(local.name_parts) > 1
    ? "${local.name_parts[0]}${var.env-suffix}.${join(".", slice(local.name_parts, 1, length(local.name_parts)))}"
    : var.name
  )
}

resource "aws_route53_record" "record" {
  allow_overwrite = null
  health_check_id = null
  name            = local.env_qualified_name
  records         = var.records
  ttl             = var.ttl
  type            = var.type
  zone_id         = var.zone_id
}
