resource "aws_cloudwatch_log_group" "backend_worker" {
  name              = "${var.env_name}-backend-worker"
  retention_in_days = 14
}

data "aws_ecs_task_definition" "backend_worker" {
  task_definition = "${var.env_name}-backend-worker"
  depends_on = [aws_ecs_task_definition.backend_worker]
}

resource "aws_ecs_task_definition" "backend_worker" {
  family = "${var.env_name}-backend-worker"

  container_definitions = <<DEFINITION
[
  {
    "command": ["bundle", "exec", "sidekiq", "-c", "3", "-q", "high_priority", "-q", "default"],
    "environment": [
      {
        "name": "RAILS_LOG_TO_STDOUT",
        "value": "true"
      },
      {
        "name": "RAILS_ENV",
        "value": "production"
      },
      {
        "name": "REDIS_CONNECTION",
        "value": "redis://${aws_elasticache_cluster.default.cache_nodes.0.address}:6379"
      },
      {
        "name": "MYSQL_CONNECTION",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["mysql_connection"]}"
      },
      {
        "name": "SECRET_KEY_BASE",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["secret_key_base"]}"
      },
      {
        "name": "INFLUXDB_API_TOKEN",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["influxdb_api_token"]}"
      },
      {
        "name": "MQTT_BROKER_HOST",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["mqtt_broker_host"]}"
      },
      {
        "name": "MQTT_BROKER_PORT",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["mqtt_broker_port"]}"
      },
      {
        "name": "GMAIL_APP_PASSWORD",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["gmail_app_password"]}"
      },
      {
        "name": "SLACK_WEBHOOK_URL",
        "value": "${jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["slack_webhook_url"]}"
      }
    ],
    "essential": true,
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repository_name_backend}:${var.backend_tag}",
    "memoryReservation": 100,
    "name": "${var.env_name}-backend-worker",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${var.env_name}-backend-worker",
        "awslogs-stream-prefix": "backend-worker"
      }
    }
  }
]
DEFINITION
}

resource "aws_ecs_service" "backend_worker" {
  name          = "${var.env_name}-backend-worker"
  cluster       = aws_ecs_cluster.default.id
  desired_count = 1

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  task_definition = "${aws_ecs_task_definition.backend_worker.family}:${max("${aws_ecs_task_definition.backend_worker.revision}", "${data.aws_ecs_task_definition.backend_worker.revision}")}"
}