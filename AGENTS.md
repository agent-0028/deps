# Instructions for AI Coding Agents

This is a shared dependencies repository — reusable Terraform modules, GitHub Actions, and other cross-project building blocks.

Consumer repos (notably [deps-examples](https://github.com/agent-0028/deps-examples)) import modules from here via git source URLs.

We use OpenTofu, so the command line tool is `tofu`.

OpenTofu v1.11.1 is compatible with Terraform v1.5.7 and earlier versions.

Many examples online will use the official Terraform command line client, `terraform`.

## Principles

This repo holds **library code**, not a deployable root stack. There is no backend, no remote state, and no environment to apply against here.

Do not run `tofu plan`, `tofu apply`, or `tofu destroy` in this repository.

Integration testing happens in consumer repos after changes are pushed to GitHub and pinned by branch or tag.

## Practices

Run `tofu fmt -recursive terraform/` before committing.

Smoke-test changed modules locally with validate only:

```bash
cd terraform/modules/<module_name>
tofu init -backend=false
tofu validate
```

Pause and allow the user to review and commit when validate passes and the diff looks correct.

Prefer focused commits — one logical change per module when practical.

## Repository layout

```
terraform/modules/
  config/              # env, env-suffix, env-prefix, repo outputs — see README.md
  bucket/              # S3 bucket with env-suffix naming — see README.md
  object/              # S3 object upload — see README.md
  hosted_zone/         # Route53 hosted zone — see README.md
  dns_record/          # Route53 record — see README.md
  dns_alias/           # Route53 alias record — see README.md
  bedrock_inference/   # Bedrock IAM, API key, inference profile — see README.md
github_actions/
  install-tofu-client/   # reusable composite action
plans/                 # design and implementation plans
```

Each module under `terraform/modules/` has a `README.md` with usage examples for consumer repos. Live wiring samples are in [deps-examples](https://github.com/agent-0028/deps-examples).

## env-suffix convention

The `config` module defines environment naming:

- **prod:** `env-suffix = ""`
- **nonprod:** `env-suffix = "-{env}"` (e.g. `-nonprod`)

Modules that create AWS-visible names should apply `env-suffix` internally so callers pass base names only — see the `bucket` module for the reference pattern.

Callers wire values from config:

```hcl
env-suffix = module.config.env-suffix
env        = module.config.env
repo       = module.config.repo
```

## Testing workflow

1. Change modules in this repo; run `tofu fmt` and `tofu validate` on affected modules.
2. Push to GitHub.
3. In a consumer repo (e.g. deps-examples), pin module sources to the branch: `?ref=<branch>`.
4. Run `tofu init -upgrade` and `tofu plan` there to integration-test.

Revert temporary branch pins in consumer repos before merging to `main`.

## What not to do here

- Do not add a root Terraform stack or backend configuration to this repo.
- Do not commit `.terraform/` directories or provider binaries (see `.gitignore`).
- Do not assume AWS credentials or run plans against live infrastructure from this repo.
