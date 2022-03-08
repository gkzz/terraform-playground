# https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
data archive_file "aws_archive_file" {
  type        = "zip"
  source_dir  = "src"
  output_path = "${var.aws_lambda_output_path}"
}

resource "aws_lambda_function" "aws_lambda_monitoring_function" {
  filename         = "${var.aws_lambda_output_path}"
  function_name    = "${var.base}"
  role             = aws_iam_role.aws_lambda_monitoring_role.arn
  handler          = "src.${base}.handler"
  source_code_hash = data.archive_file.aws_archive_file.output_base64sha256
  runtime          = "nodejs14.x"
  memory_size      = 128
  timeout          = 300
  environment {
    variables = {
     SLACK_WEBHOOK_URL = "${var.slack_webhook_url}"
    }
  }
}

resource "aws_iam_role" "aws_lambda_monitoring_role" {
  name = "${var.base}_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "aws_lambda_monitoring_policy_attachment" {
  role       = aws_iam_role.aws_lambda_monitoring_role.name
  # https://learn.hashicorp.com/tutorials/terraform/lambda-api-gateway
  #policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}


resource "aws_lambda_permission" "aws_lambda_monitoring_permisson" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.aws_lambda_monitoring_function.function_name
  principal     = "sns.amazonaws.com"
  source_arn    = aws_sns_topic.aws_lambda_monitoring_topic.arn
}