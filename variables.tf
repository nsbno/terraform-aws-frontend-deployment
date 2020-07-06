variable "frontend_applications" {
  description = "A list of maps that detail which ZIP files to unzip to which buckets."
  type        = list(map(string))
}

variable "lambda_alias_prefix" {
  description = "The prefix of the Lambda alias that is used to authorize cross-account invocations."
  default     = "account-"
  type        = string
}

variable "lambda_owner" {
  description = "The ID of the account that owns the Lambda function to invoke."
  type        = string
}

variable "lambda_name" {
  description = "The name of the Lambda function to invoke."
  type        = string
}

variable "role_name" {
  description = "The name of the cross-account role to create."
  type        = string
}
