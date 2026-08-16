# bedrock_inference

Terraform module (library code in **deps**) that provisions a narrow Bedrock inference setup:

- An application inference profile (optional)
- An IAM user and Bedrock service-specific credential (optional API key)
- IAM scoped to one configured model across **bedrock-runtime** and **bedrock-mantle** paths

Tier → model ID mappings live in `tiers.tf`. Consumer repos import this module via git source and apply it in their own root stacks (see [deps-examples](https://github.com/agent-0028/deps-examples)).

This directory has **no backend and no remote state**. Do not run `tofu apply` here.

## Usage in a consumer repo

```hcl
module "bedrock_inference" {
  source = "git::https://github.com/agent-0028/deps.git//terraform/modules/bedrock_inference?ref=main"

  attributes = { tier = "fast", vendor = "openai" }
  env-suffix = module.config.env-suffix
  env        = module.config.env
  repo       = module.config.repo
}
```

Wire `env`, `env-suffix`, and `repo` from the deps `config` module. Key outputs for client wiring: `model_id`, `provision_model_id`, `openai_mantle_base_url`, `openai_base_url`, `api_key`, `pi_command`.

## Bedrock vs mantle (two endpoints, one product)

Amazon Bedrock exposes two inference HTTP endpoints. Both are fully managed; neither requires Lambda or self-hosted model infra.

| Endpoint | Host | Typical APIs |
|----------|------|--------------|
| **bedrock-runtime** | `bedrock-runtime.{region}.amazonaws.com` | Converse, InvokeModel, runtime Chat Completions |
| **bedrock-mantle** | `bedrock-mantle.{region}.api.aws` | OpenAI-compatible Chat Completions / Responses; Anthropic Messages |

This module provisions **runtime-side** resources (inference profile, `bedrock:InvokeModel*`) and outputs URLs/IDs for **both** paths so consumer apps can pick the client SDK they use.

Mantle is not a separate cloud product — it is Bedrock’s OpenAI/Anthropic-compatible front door. Model availability differs by endpoint; see AWS [endpoint availability](https://docs.aws.amazon.com/bedrock/latest/userguide/models-endpoint-availability.html).

## Model IDs: mantle vs provision

Bedrock often uses **different model ID strings** for the same logical model depending on endpoint. Each vendor×tier cell in `tiers.tf` stores both:

| Field in `tiers.tf` | Output | Used for |
|---------------------|--------|----------|
| `mantle_model_id` | `model_id` | Mantle clients (OpenAI SDK Chat Completions on `openai_mantle_base_url`; Anthropic Messages on mantle) |
| `provision_model_id` | `provision_model_id` | IAM invoke scope, application inference profile, Converse / Pi / runtime paths |

When they differ (e.g. mantle `openai.gpt-oss-20b` vs runtime `openai.gpt-oss-20b-1:0`), pass **`model_id`** to mantle/OpenAI-compatible clients and **`provision_model_id`** (or `pi_command`) to runtime clients.

Set **`attributes.model_id`** instead of tier/vendor to pin a single ID for both outputs (escape hatch).

### Maintaining `tiers.tf`

The tier map is maintained by hand against AWS model cards — Bedrock does not expose one universal ID list across endpoints.

- **OpenAI-compat mantle catalog** (`GET …/v1/models`): mostly open-weight models; Anthropic entries are sparse (Haiku is a common exception).
- **Anthropic on mantle**: Messages API (`/anthropic/v1/messages`), not the OpenAI `/v1/models` list.
- **Runtime catalog**: `ListFoundationModels` / model cards for `provision_model_id`.

After changing IDs here, run `tofu test` in this module, then plan/apply in a consumer repo. [deps-examples](https://github.com/agent-0028/deps-examples) includes post-deploy scripts under `terraform/scripts/` (smoke test, model discovery) — those live in the consumer repo, not in deps.

## Vendor × endpoint

Amazon hosts the HTTP endpoints; this module does not. Pick the base URL and model output for your client:

| Vendor | Primary client path | Base URL output | Model output |
|--------|---------------------|-----------------|--------------|
| `openai` | Mantle Chat Completions (OpenAI SDK) | `openai_mantle_base_url` | `model_id` |
| `indie` | Mantle Chat Completions (OpenAI SDK) | `openai_mantle_base_url` | `model_id` |
| `anthropic` | Runtime Converse / Pi; or Anthropic Messages on mantle | `openai_base_url` or mantle Messages base | `provision_model_id` for Pi/runtime; `model_id` for mantle Messages |

Anthropic on mantle uses the **Messages API**, not `openai_mantle_base_url` Chat Completions. For OpenAI SDK smoke tests in consumer repos, prefer **`vendor = "openai"` or `"indie"`**.

## IAM scope

When `create_api_key = true` (default), the module API key can invoke only the configured model:

| Path | IAM | Scope |
|------|-----|-------|
| Runtime / Converse / Pi | `bedrock:InvokeModel*` | Application inference profile + `provision_model_id` source ARN |
| Mantle Chat Completions | `bedrock-mantle:CreateInference` | `bedrock-mantle:Model` condition = `model_id` output |
| Mantle API key auth | `bedrock-mantle:CallWithBearerToken` | `Resource = "*"` (auth-only; AWS requires this for bearer tokens) |

Wrong mantle model IDs in client requests should fail after deploy. `CallWithBearerToken` on `*` does not grant inference by itself — it only enables bearer-token authentication; model access is enforced on `CreateInference`.

Listing models (`bedrock-mantle:ListModels`, `bedrock:ListFoundationModels`) is **not** granted to the inference user; use broader credentials in consumer-repo maintainer tooling when updating `tiers.tf`.

## Unit tests (this repo)

Tests live in `tests/` and use **mocked** AWS providers — no credentials, no remote state, no consumer environments.

From this directory:

```bash
tofu init    # once per clone; local provider only, no backend
tofu test
```

Also run after changes:

```bash
tofu fmt
tofu validate
```

## Integration testing (consumer repos)

1. Push module changes to deps.
2. In a consumer repo (e.g. deps-examples), temporarily pin `?ref=<branch>` on the module source.
3. Run `tofu init -upgrade` and `tofu plan` against that repo’s environment stack.
4. After merge, use post-deploy scripts in the consumer repo if present (see deps-examples `terraform/scripts/README.md`).

Revert temporary branch pins before merging consumer changes to `main`.
