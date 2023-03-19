# Outputs
output "function_arn" {
  description = "The ARN of the Lambda function"
  value       =  aws_lambda_function.s3_delete_lambda.arn
}

output "function_name" {
  description = "The name of the Lambda function"
  value       =  aws_lambda_function.s3_delete_lambda.function_name
}

output "role_arn" {
  description = "The ARN of the IAM role created for the Lambda function"
  value       = aws_iam_role.delete_s3_lambda_role.arn 
}

output "role_name" {
  description = "The name of the IAM role created for the Lambda function"
  value       = aws_iam_role.delete_s3_lambda_role.name
}