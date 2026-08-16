# object

Terraform module (library code in **deps**) that uploads a single S3 object (inline `content` or metadata you extend later).

Useful for config blobs, placeholder files, or examples where object body differs per environment. Consumer repos pass `content` from their stack — see [deps-examples](https://github.com/agent-0028/deps-examples) (`example_object_content` threaded through the local stack module).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "example_object" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/object?ref=main"

  bucket       = module.example_bucket.current_bucket
  key          = "example-object.txt"
  content_type = "text/plain"
  content      = var.example_object_content
  env-suffix   = module.config.env-suffix
  env          = module.config.env
  repo         = module.config.repo
}
```

The bucket name comes from the `bucket` module output, not a constructed string.

## Inputs

| Variable | Required | Default | Purpose |
|----------|----------|---------|---------|
| `bucket` | yes | — | Target bucket name |
| `key` | yes | — | Object key |
| `content` | yes | — | Object body (UTF-8 string) |
| `content_type` | yes | — | S3 content type |
| `env` | yes | — | Tag `Environment` |
| `repo` | yes | — | Tag `Repo` |
| `env-suffix` | no | `"dev"` | Accepted for call-site consistency; not used in resource naming |
| `server_side_encryption` | no | `AES256` | SSE algorithm |
| `storage_class` | no | `STANDARD` | S3 storage class |
| `bucket_key_enabled` | no | `false` | Bucket key for SSE-KMS |
| `website_redirect` | no | `null` | Optional redirect target |

## Outputs

This module defines no outputs. Depend on the bucket module or parent stack for names and ARNs.

## Validation (this repo)

```bash
tofu init -backend=false
tofu validate
tofu fmt
```

## Integration testing (consumer repos)

Plan/apply in a consumer repo and confirm object `content` updates in place when the stack variable changes.
