# config

Terraform module (library code in **deps**) that centralizes environment naming and shared settings for other modules in this repo.

Consumer repos import it once per root stack and pass its outputs (`env-suffix`, `env`, `repo`, etc.) into resource modules. See [deps-examples](https://github.com/agent-0028/deps-examples) for a full wiring pattern (config at the environment root, then a local `stack` module).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "config" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/config?ref=main"
  env    = "nonprod"
  repo   = var.repo
}
```

Pass `env` explicitly per environment (`"prod"`, `"nonprod"`, etc.). Other modules receive:

```hcl
env-suffix = module.config.env-suffix
env        = module.config.env
repo       = module.config.repo
```

Alternatively, build a config object at the root and pass it into a local stack module — see deps-examples `terraform/prod/stack.tf` and `terraform/nonprod/stack.tf`.

## Outputs

| Output | prod (`env = "prod"`) | nonprod example (`env = "nonprod"`) |
|--------|------------------------|-------------------------------------|
| `env-suffix` | `""` | `"-nonprod"` |
| `env-prefix` | `""` | `"nonprod-"` |
| `env` | `"prod"` | `"nonprod"` |
| `is-prod` | `true` | `false` |
| `repo` | caller value | caller value |
| `aws_region` | `us-west-2` (default) | same |

## env-suffix convention

**prod** uses no suffix on resource names. **All other environments** append `env-suffix` (`"-{env}"`) so prod and nonprod can coexist in one AWS account without name collisions.

Modules such as `bucket` and `hosted_zone` apply `env-suffix` internally. Callers pass base names only.

## Inputs

| Variable | Default | Purpose |
|----------|---------|---------|
| `env` | `"dev"` | Environment name; `"prod"` triggers prod naming |
| `repo` | `"grosgrain-change-me"` | Tag value and logical repo identifier |
| `aws_region` | `"us-west-2"` | Region output for provider wiring |

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Plan and apply in a consumer repo’s environment stack after changing this module. No unit tests live here; behavior is exercised through downstream modules.
