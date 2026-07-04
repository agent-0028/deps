locals {
  name_parts = split(".", var.name)

  env_qualified_name = (
    var.env-suffix != "" && length(local.name_parts) > 1
    ? "${local.name_parts[0]}${var.env-suffix}.${join(".", slice(local.name_parts, 1, length(local.name_parts)))}"
    : var.name
  )
}

resource "aws_route53_zone" "zone" {
  comment       = "HostedZone created by Route53 Registrar"
  force_destroy = false
  name          = local.env_qualified_name
  tags = {
    Repo        = var.repo
    Environment = var.env
  }
}

output "dns_records" {
  # Not really sure why we need to append dots to the values output from the aws_route53_zone resource
  # The example in this article doesn't seem to need that:
  # https://renehernandez.io/tutorials/terraforming-dns-with-aws-route53/#configuring-zone-and-nameservers
  value = [for i, v in aws_route53_zone.zone.name_servers : "${v}."]
}

output "soa_dns_records" {
  # the end bit is auto generated and hard coded here until I understand more
  # in the AWS web console, you don't see "awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"
  # but adding it here gives me a green plan
  # also adding the silly dot at the end, but no need to do a loop, only one SOA record
  value = ["${aws_route53_zone.zone.primary_name_server}. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
}

output "id" {
  value = aws_route53_zone.zone.id
}

output "qualified_name" {
  value = aws_route53_zone.zone.name
}