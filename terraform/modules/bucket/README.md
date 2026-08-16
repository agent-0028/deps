# bucket

Terraform module (library code in **deps**) that creates an S3 bucket with `env-suffix` naming and standard tags.

Consumer repos import this module via git source. Working examples live in [deps-examples](https://github.com/agent-0028/deps-examples) (`terraform/modules/stack/bucket.tf`).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "example_bucket" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/bucket?ref=main"

  attributes = {
    bucket = "my-app-data"
  }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}
```

## Naming

The AWS bucket name is `"${attributes.bucket}${env-suffix}"`.

| `attributes.bucket` | `env-suffix` | Result |
|-----------------------|--------------|--------|
| `my-app-data` | `""` (prod) | `my-app-data` |
| `my-app-data` | `-nonprod` | `my-app-data-nonprod` |

Optional `attributes.bucket_prefix` is passed through to `aws_s3_bucket` when set (mutually exclusive with a fixed `bucket` name in AWS; use one pattern per bucket).

## Outputs

| Output | Description |
|--------|-------------|
| `current_bucket` | Resolved bucket name (same as created name) |

Downstream modules (e.g. `object`) should use `current_bucket`, not hardcode the suffixed name.

## Inputs

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `attributes.bucket` | yes | — | Base bucket name (suffix applied by module) |
| `attributes.bucket_prefix` | no | — | Optional prefix mode for AWS-generated suffix |
| `env-suffix` | yes | — | From `config` module |
| `env` | yes | — | Tag `Environment` |
| `repo` | yes | — | Tag `Repo` |
| `object_ownership` | no | `BucketOwnerPreferred` | Ownership controls rule |

## Resources

Creates `aws_s3_bucket`, `aws_s3_bucket_ownership_controls`, and a read-back `data.aws_s3_bucket` for the output.

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Push changes to deps, pin `?ref=<branch>` in a consumer repo, then `tofu plan` in that repo’s environment stack.
