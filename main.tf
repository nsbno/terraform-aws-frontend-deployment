data "aws_caller_identity" "current-account" {}
data "aws_region" "current" {}

locals {
  current_region = data.aws_region.current.name
  function_name  = var.lambda_alias_prefix == "" ? "arn:aws:lambda:${local.current_region}:${var.lambda_owner}:function:${var.lambda_name}" : "arn:aws:lambda:${local.current_region}:${var.lambda_owner}:function:${var.lambda_name}:${var.lambda_alias_prefix}${local.current_account_id}"

  current_account_id = data.aws_caller_identity.current-account.account_id
  frontend_deployment_payload = {
    account_id             = local.current_account_id
    role_to_assume         = aws_iam_role.cross_account.name
    s3_source_target_pairs = var.frontend_applications
  }
}


##################################
#                                #
# Cross-account role             #
#                                #
##################################
resource "aws_iam_role" "cross_account" {
  name               = var.role_name
  assume_role_policy = data.aws_iam_policy_document.cross_account_lambda_assume.json
}

resource "aws_iam_role_policy" "s3_to_cross_account" {
  count  = length(local.frontend_deployment_payload.s3_source_target_pairs) > 0 ? 1 : 0
  policy = data.aws_iam_policy_document.s3_for_cross_account.json
  role   = aws_iam_role.cross_account.id
}


##################################
#                                #
# Frontend deployment            #
#                                #
##################################
resource "null_resource" "frontend_deployment" {
  count = length(local.frontend_deployment_payload.s3_source_target_pairs)
  triggers = {
    payload = sha256(jsonencode(local.frontend_deployment_payload.s3_source_target_pairs[count.index]))
  }
  provisioner "local-exec" {
    interpreter = ["/usr/bin/env", "sh", "-c"]
    command     = "test \"$(aws sts get-caller-identity --query 'Account' --output text)\" = \"${local.current_account_id}\" && aws lambda invoke --function-name ${local.function_name} --payload '${jsonencode(merge(local.frontend_deployment_payload, { s3_source_target_pairs = [local.frontend_deployment_payload.s3_source_target_pairs[count.index]] }))}' out.json > response.json && cat response.json | if grep -q FunctionError; then cat response.json out.json && exit 1; fi"
  }
  depends_on = [aws_iam_role_policy.s3_to_cross_account]
}
