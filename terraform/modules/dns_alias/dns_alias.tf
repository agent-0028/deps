
resource "aws_route53_record" "record" {
  allow_overwrite = null
  health_check_id = null
  name            = var.name
  type            = "A"
  zone_id         = var.zone_id
  alias {
    evaluate_target_health = var.evaluate_target_health
    name                   = var.value
    zone_id                = var.alias_zone_id
  }
}
