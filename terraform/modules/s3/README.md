# S3 Module

This Terraform module provisions a production-ready AWS S3 bucket with KMS encryption, versioning, lifecycle management, and optional IAM user access.

## Usage

```hcl
module "s3" {
  source = "./modules/s3"

  project     = "myapp"
  environment = "production"

  common_tags = {
    ManagedBy = "Terraform"
  }

  kms_key_id  = aws_kms_key.main.key_id
  kms_key_arn = aws_kms_key.main.arn

  enable_versioning  = true
  enable_iam_user    = true
  enable_eventbridge = true
  enable_metrics     = true

  lifecycle_rules = [
    {
      id      = "expire-old-objects"
      enabled = true
      prefix  = "logs/"
      expiration_days                    = 90
      noncurrent_version_expiration_days = 30
    }
  ]

  cors_rules = [
    {
      allowed_methods = ["GET", "PUT"]
      allowed_origins = ["https://example.com"]
      allowed_headers = ["*"]
    }
  ]
}
```

## Features

- **KMS Encryption** — SSE-KMS with bucket key enabled; SSE-C blocked
- **Public Access Block** — all public access blocked by default
- **Versioning** — enabled or suspended via variable
- **IAM Policy** — grants configurable S3 actions and KMS decrypt/generate permissions
- **IAM User** — optional dedicated IAM user with the policy attached
- **Lifecycle Rules** — configurable expiration and transition rules
- **CORS** — configurable CORS rules
- **EventBridge** — optional bucket event notifications
- **Metrics** — optional S3 request metrics for the entire bucket
- **Access Logging** — optional, to a target bucket

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project` | Application name used as namespace prefix | `string` | — | ✅ |
| `environment` | Environment name used as namespace prefix | `string` | — | ✅ |
| `common_tags` | Common tags applied to all resources | `map(string)` | — | ✅ |
| `kms_key_id` | KMS key ID for bucket encryption | `string` | — | ✅ |
| `kms_key_arn` | KMS key ARN for IAM policy | `string` | — | ✅ |
| `bucket_name` | Override bucket name. Defaults to `<environment>-<project>-s3` | `string` | `null` | ❌ |
| `enable_versioning` | Enable S3 bucket versioning | `bool` | `true` | ❌ |
| `enable_eventbridge` | Enable EventBridge notifications | `bool` | `false` | ❌ |
| `enable_metrics` | Enable S3 request metrics | `bool` | `false` | ❌ |
| `enable_iam_user` | Create a dedicated IAM user | `bool` | `true` | ❌ |
| `iam_user_name` | Override IAM user name. Defaults to `<environment>-<project>-s3-user` | `string` | `null` | ❌ |
| `allowed_s3_actions` | S3 actions to allow in the IAM policy | `list(string)` | See below | ❌ |
| `lifecycle_rules` | List of lifecycle rules | `list(object)` | `[]` | ❌ |
| `cors_rules` | List of CORS rules | `list(object)` | `[]` | ❌ |
| `logging_target_bucket` | Target bucket for access logging. If null, logging is disabled | `string` | `null` | ❌ |
| `logging_target_prefix` | Prefix for access log objects | `string` | `"logs/"` | ❌ |
| `force_destroy` | Allow destroying a non-empty bucket | `bool` | `false` | ❌ |

### Default `allowed_s3_actions`

```hcl
[
  "s3:PutObject",
  "s3:GetObject",
  "s3:DeleteObject",
  "s3:ListBucket",
  "s3:PutObjectAcl",
  "s3:GetObjectAcl"
]
```

### `lifecycle_rules` object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `id` | `string` | ✅ | Rule identifier |
| `enabled` | `bool` | ✅ | Enable or disable the rule |
| `prefix` | `string` | ❌ | Object key prefix filter (default: `""`) |
| `expiration_days` | `number` | ❌ | Days until object expiration |
| `noncurrent_version_expiration_days` | `number` | ❌ | Days until noncurrent version expiration |
| `transition` | `list(object)` | ❌ | List of `{ days, storage_class }` transitions |

### `cors_rules` object

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `allowed_methods` | `list(string)` | ✅ | HTTP methods (e.g. `GET`, `PUT`) |
| `allowed_origins` | `list(string)` | ✅ | Allowed origin patterns |
| `allowed_headers` | `list(string)` | ❌ | Allowed request headers |
| `expose_headers` | `list(string)` | ❌ | Headers to expose to the browser |
| `max_age_seconds` | `number` | ❌ | Browser cache time for preflight responses |

## Outputs

| Name | Description |
|------|-------------|
| `s3_bucket_name` | Name of the S3 bucket |
| `s3_bucket_arn` | ARN of the S3 bucket |
| `s3_bucket_id` | ID of the S3 bucket |
| `s3_policy_arn` | ARN of the IAM policy for S3 access |
| `s3_user_name` | Name of the IAM user (`null` if `enable_iam_user` is `false`) |
| `s3_user_arn` | ARN of the IAM user (`null` if `enable_iam_user` is `false`) |