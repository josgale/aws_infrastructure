# IAM role for the lambda function
resource "aws_iam_role" "delete_s3_lambda_role" {
  name = "delete_s3_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

#IAM policy to allow lambda to list and delete objects in s3
resource "aws_iam_role_policy" "s3_policy_for_lambda" {
  name = "s3_policy_for_lambda"
  role = aws_iam_role.delete_s3_lambda_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:HeadObject",
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject"
        ]
        Resource = [
          "*",
        ]
      }
    ]
  })
}

#IAM policy to allow lambda to send email via SES
resource "aws_iam_role_policy" "ses_policy_for_lambda" {
  name = "ses_policy_for_lambda"
  role = aws_iam_role.delete_s3_lambda_role.id

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:*"
            ]
        Resource = [ 
          "*",
        ]
        }
    ]
}
    
  )
}