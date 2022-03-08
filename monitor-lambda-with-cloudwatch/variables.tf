variable "aws_access_key" {}

variable "aws_secret_key" {}

variable "aws_account_id" {}

variable "region" {
  default = "ap-northeast-1"
}

variable "prefix" {
  default = "aws_lambda"
}

variable "alarms_associated_metric" {
  type = map
  default = {
    "FunctionName" = "slack_notify"
  }
}

variable "aws_lambda_alert_function_name" {
  default = "aws_lambda_alarm_firing"
}
