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
  /*
  * NOTE: Without this dependency, the policy document will not be updated the first time
  * `var.frontend_applications` has been edited (e.g., new name of a target bucket), and `apply`
  * must be run twice. This dependency, however, forces the recreation of the policy document
  * if the input variable has changed.
  */
  depends_on = [var.frontend_applications]
}
