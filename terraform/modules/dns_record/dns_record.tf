
resource "aws_route53_record" "record" {
  allow_overwrite = null
  health_check_id = null
  name            = var.name
  records         = var.records
  ttl             = var.ttl
  type            = var.type
  zone_id         = var.zone_id
}
