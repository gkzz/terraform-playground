data archive_file "default" {
  type        = "zip"
  source_dir  = "src"
  output_path = var.output_path
}

resource "aws_lambda_function" "default" {
  filename         = var.output_path
  function_name    = var.service_name
  role             = aws_iam_role.default.arn
  handler          = "lambda_function.lambda_handler"
  source_code_hash = data.archive_file.default.output_base64sha256
  runtime          = "python3.6"
  environment {
    variables = {
      SLACK_API_KEY = var.SLACK_API_KEY
    }
  }
}