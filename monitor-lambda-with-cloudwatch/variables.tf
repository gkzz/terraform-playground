variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_account_id" {}

variable "slack_webhook_url" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "base" {
  default = "aws_lambda_monitoring"
}

variable "alarms_associated_metric" {
  type = map
  default = {
    "FunctionName" = "slack_notify"
  }
}

variable "aws_lambda_output_path" {
  default = "aws_lambda_monitoring.js"
}
