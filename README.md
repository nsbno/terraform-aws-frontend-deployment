# terraform-aws-frontend-deployment
A Terraform module that facilitates the deployment of static frontend applications, where a _deployment_ entails the unzipping of a source ZIP file (i.e., a frontend bundle) to a target S3 bucket.

The main use-case is to utilize the module in specific environments (e.g., a _test_, _stage_ or _prod_ AWS account) to provide a seamless deployment model for frontend applications. The deployment mechanism is based on the invocation of a Lambda function owned by account A, a facilitating _service_ account, which when called will download one or more application artifacts and unzip each of them to specific target buckets that are owned by account B, the caller.

See [example](example/) for an example of a full set up.

## Requirements
- The Lambda function https://github.com/nsbno/terraform-aws-pipeline-unzip-to-bucket provisioned in account A, a facilitating _service_ account, with permissions to assume cross-account roles.
- `aws-cli` installed (both v1.x and v2.x is supported).
- `/usr/bin/env sh` available.
