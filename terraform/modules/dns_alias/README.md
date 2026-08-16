# dns_alias

Terraform module (library code in **deps**) that creates a Route53 **A alias** record (e.g. to S3 website, CloudFront, ELB).

Pairs with `hosted_zone`. The alias **target** (`value`, `alias_zone_id`) is caller-supplied — this module only creates the Route53 alias record. S3 website buckets and policies are typically defined in the consumer stack; see [deps-examples](https://github.com/agent-0028/deps-examples) (`terraform/modules/stack/dns-alias.tf`).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "example_dns_alias" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/dns_alias?ref=main"

  name                   = "www"
  zone_id                = module.example_hosted_zone.id
  value                  = aws_s3_bucket_website_configuration.example.website_endpoint
  alias_zone_id          = "Z3BJ6K6RIION7M" # S3 website hosted zone ID for the bucket region
  evaluate_target_health = false
  env-suffix             = module.config.env-suffix
  env                    = module.config.env
}
```

S3 static website aliases require the bucket name to match the record FQDN. Build the bucket name from `module.example_hosted_zone.qualified_name` in the consumer stack.

## Record naming (`env-suffix`)

Same first-label suffix rule as `dns_record` and `hosted_zone`. Relative names like `www` are unchanged when they are a single label; the zone’s `qualified_name` carries environment separation.

## Inputs

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `zone_id` | yes | `""` | Hosted zone ID |
| `name` | no | `example.com` | Alias record name |
| `value` | no | `""` | Alias target DNS name (e.g. S3 website endpoint) |
| `alias_zone_id` | no | `""` | Hosted zone ID of the target service |
| `evaluate_target_health` | no | `false` | Route53 alias health evaluation |
| `env-suffix` | yes | — | From `config` module |
| `env` | yes | — | Required by module signature |

Record type is always **A** (alias).

## Outputs

This module defines no outputs.

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Plan/apply in a consumer repo. Confirm the alias resolves and the target endpoint serves content.

Common S3 website `alias_zone_id` values are region-specific; see [AWS documentation](https://docs.aws.amazon.com/general/latest/gr/s3.html#s3_website_region_endpoints).
