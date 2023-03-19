# Zip Python file for Lambda function
data "archive_file" "lambda_zip" {
  type             = "zip"
  source_file      = "${path.module}./src/delete_objects.py"
  output_file_mode = "0666"
  output_path      = "${path.module}/bin/delete_objects.zip"
}

# Create Lambda function
resource "aws_lambda_function" "s3_delete_lambda" {
  runtime          = "python3.9"
  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "s3_delete_lambda"
  handler          = "delete_objects.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  role             = aws_iam_role.delete_s3_lambda_role.arn
  

  environment {
    variables = {
      bucket_name = var.bucket_name
      target_email = var.target_email
    }
  }
}

# Cron event rule
resource "aws_cloudwatch_event_rule" "every_sunday" {
  name = "every_sunday"
  schedule_expression = "cron(0 1 ? * SUN *)"
}

# CloudWatch permissions to invoke our function
resource "aws_lambda_permission" "allow_cloudwatch_to_invoke" {
  function_name = "s3_delete_lambda"
  statement_id = "CloudWatchInvoke"
  action = "lambda:InvokeFunction"

  source_arn = aws_cloudwatch_event_rule.every_sunday.arn
  principal = "events.amazonaws.com"
}

# Event target 
resource "aws_cloudwatch_event_target" "invoke_lambda" {
  rule = aws_cloudwatch_event_rule.every_sunday.name
  arn = aws_lambda_function.s3_delete_lambda.arn
}