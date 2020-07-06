data "aws_iam_policy_document" "cross_account_lambda_assume" {
  # TODO: Make these more restricted / avoid hardcoding
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${var.lambda_owner}:root"]
    }
  }
}

data "aws_iam_policy_document" "s3_for_cross_account" {
  count = length(local.frontend_deployment_payload.s3_source_target_pairs) > 0 ? 1 : 0
  statement {
    effect    = "Allow"
    actions   = ["s3:ListAllMyBuckets"]
    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:ListBucket"]
    resources = formatlist("arn:aws:s3:::%s", [for pair in local.frontend_deployment_payload.s3_source_target_pairs : pair["s3_target_bucket"]])
  }

  statement {
    effect    = "Allow"
    actions   = ["s3:Get*", "s3:Delete*", "s3:Put*"]
    resources = formatlist("arn:aws:s3:::%s/*", [for pair in local.frontend_deployment_payload.s3_source_target_pairs : pair["s3_target_bucket"]])
  }
}
