# dns_record

Terraform module (library code in **deps**) that creates a Route53 record (TXT, A, CNAME, etc.) in an existing zone.

Pairs with `hosted_zone`. Examples: [deps-examples](https://github.com/agent-0028/deps-examples) (`terraform/modules/stack/dns-record.tf`).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "example_dns_record" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/dns_record?ref=main"

  name       = "verify"
  type       = "TXT"
  records    = ["my-verification-token"]
  ttl        = 300
  zone_id    = module.example_hosted_zone.id
  env-suffix = module.config.env-suffix
  env        = module.config.env
}
```

## Record naming (`env-suffix`)

The same first-label suffix rule as `hosted_zone` applies when `name` contains multiple labels:

| `name` | `env-suffix` | Record FQDN (in zone) |
|--------|--------------|------------------------|
| `verify` | `-nonprod` | `verify` (single label — unchanged) |
| `api.example.com` | `-nonprod` | `api-nonprod.example.com` |

For simple relative names like `verify` or `www`, suffixing is usually handled at the **zone** level (`hosted_zone`), not the record label.

## Inputs

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `zone_id` | yes | `""` | Hosted zone ID |
| `name` | no | `example.com` | Record name (relative or FQDN) |
| `type` | no | `""` | Record type (`TXT`, `A`, …) |
| `records` | no | `[]` | RDATA values |
| `ttl` | no | `172800` | TTL seconds |
| `env-suffix` | yes | — | From `config` module |
| `env` | yes | — | Required by module signature (tagging consistency) |

## Outputs

This module defines no outputs.

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Plan/apply in a consumer repo and verify record presence with `dig` or the Route53 console.
