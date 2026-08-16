# hosted_zone

Terraform module (library code in **deps**) that creates a Route53 hosted zone with environment-qualified naming.

Consumer examples: [deps-examples](https://github.com/agent-0028/deps-examples) (`terraform/modules/stack/hosted-zone.tf`).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "example_hosted_zone" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/hosted_zone?ref=main"

  name       = "myapp.example.com"
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}
```

## Naming (`env-suffix` in the zone FQDN)

When `env-suffix` is non-empty and `name` has more than one DNS label, the **first label** gets the suffix:

| `name` | `env-suffix` | Zone created |
|--------|--------------|--------------|
| `myapp.example.com` | `-nonprod` | `myapp-nonprod.example.com` |
| `myapp.example.com` | `""` (prod) | `myapp.example.com` |

Pass the logical base zone name from config; the module applies suffixing. Delegate the resulting zone from the parent domain (NS records) outside this module.

## Outputs

| Output | Description |
|--------|-------------|
| `id` | Route53 zone ID (for `dns_record` / `dns_alias`) |
| `qualified_name` | Actual zone FQDN after suffixing |
| `dns_records` | NS records (with trailing dots) |
| `soa_dns_records` | SOA record string for import/plan stability |

Downstream records should use `qualified_name` when building FQDNs (e.g. S3 website bucket names).

## Inputs

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `name` | no | `example.com` | Base zone name |
| `env-suffix` | yes | — | From `config` module |
| `env` | yes | — | Tag `Environment` |
| `repo` | yes | — | Tag `Repo` |

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Plan/apply in a consumer repo. Confirm NS delegation and that `dns_record` / `dns_alias` modules target `module.*.id`.

See also `plans/DNS-ENV-SUFFIX-PLAN.md` at the deps repo root for design notes on DNS suffix behavior.
