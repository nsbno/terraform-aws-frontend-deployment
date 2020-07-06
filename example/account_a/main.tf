variable "trusted_account_id" {
  description = "The ID of an account that is allowed to invoke the Lambda function."
  type        = string
}

variable "service_account_id" {
  description = "The ID of the account that owns the Lambda function to be invoked."
  type        = string
}

variable "source_bucket" {
  description = "The name of a source bucket containing frontend bundles."
  type        = string
}

provider "aws" {
  region              = "eu-west-1"
  allowed_account_ids = [var.service_account_id]
}

##################################
#                                #
# unzip-to-bucket Lambda         #
#                                #
##################################
module "unzip-to-bucket" {
  source           = "github.com/nsbno/terraform-aws-pipeline-unzip-to-bucket?ref=bc43273"
  name_prefix      = "terraform-example"
  trusted_accounts = [var.trusted_account_id]
}

resource "aws_iam_role_policy" "role_assume_to_unzip_to_bucket" {
  role   = module.unzip-to-bucket.lambda_exec_role_id
  policy = data.aws_iam_policy_document.role_assume.json
}

resource "aws_iam_role_policy" "s3_to_unzip_to_bucket" {
  role   = module.unzip-to-bucket.lambda_exec_role_id
  policy = data.aws_iam_policy_document.s3_for_unzip_to_bucket.json
}


data "aws_iam_policy_document" "role_assume" {
  statement {
    effect    = "Allow"
    actions   = ["sts:AssumeRole"]
    resources = ["arn:aws:iam::${var.trusted_account_id}:role/terraform-example-unzip-to-bucket-cross-account"]
  }
}

data "aws_iam_policy_document" "s3_for_unzip_to_bucket" {
  statement {
    effect    = "Allow"
    actions   = ["s3:Get*", "s3:List*"]
    resources = ["arn:aws:s3:::${var.source_bucket}", "arn:aws:s3:::${var.source_bucket}/*"]
  }
}
