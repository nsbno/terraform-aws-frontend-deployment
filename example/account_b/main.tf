variable "trusted_account_id" {
  description = "The ID of an account that is allowed to invoke the Lambda function."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the service account that owns the Lambda to invoke."
  type        = string
}

variable "source_bucket" {
  description = "The name of a source bucket containing frontend bundles."
  type        = string
}

variable "source_key" {
  description = "The S3 key of a ZIP file located in the source bucket."
  type        = string
}

variable "target_bucket" {
  description = "The name of a target bucket to unzip the frontend bundle to."
  type        = string
}

provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = [var.trusted_account_id]
}

module "frontend_deployment" {
  source       = "../../"
  lambda_name  = "terraform-example-pipeline-unzip-to-bucket"
  lambda_owner = var.service_account_id
  role_name    = "terraform-example-unzip-to-bucket-cross-account"
  frontend_applications = [
    {
      s3_source_bucket = var.source_bucket
      s3_source_key    = var.source_key
      s3_target_bucket = var.target_bucket
    }
  ]
}
