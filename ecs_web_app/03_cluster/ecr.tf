# this is the ECR repo to which Docker images will be pushed for use by ECS
resource "aws_ecr_repository" "backend" {
  name = var.ecr_repository_name_backend
}

resource "aws_ecr_repository" "frontend" {
  name = var.ecr_repository_name_frontend
}
resource "aws_ecr_lifecycle_policy" "backend_policy" {
  repository = "${aws_ecr_repository.backend.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "frontend_policy" {
  repository = "${aws_ecr_repository.frontend.name}"

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 7 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 7
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}
