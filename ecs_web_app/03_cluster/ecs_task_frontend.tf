resource "aws_cloudwatch_log_group" "frontend" {
  name              = "${var.env_name}-frontend"
  retention_in_days = 14
}

resource "aws_ecs_task_definition" "frontend" {
  family = "${var.env_name}-frontend"

  container_definitions = <<DEFINITION
[
  {
    "portMappings": [
      {
        "containerPort": 80
      }
    ],
    "environment": [],
    "essential": true,
    "image": "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/${var.ecr_repository_name_frontend}:${var.frontend_tag}",
    "memoryReservation": 250,
    "name": "${var.env_name}-frontend",
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-region": "${data.aws_region.current.name}",
        "awslogs-group": "${var.env_name}-frontend",
        "awslogs-stream-prefix": "frontend"
      }
    },
    "network_mode": "host"
  }
]
DEFINITION
}

data "aws_ecs_task_definition" "frontend" {
  task_definition = "${var.env_name}-frontend"
  depends_on = [aws_ecs_task_definition.frontend]
}

resource "aws_lb_target_group" "frontend" {
  name     = "${var.env_name}-frontend"
  port     = "80"
  protocol = "HTTP"
  vpc_id   = "${aws_vpc.app.id}"
  deregistration_delay = "15"

  depends_on = [aws_lb.lb]

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "301,302,200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }

}

resource "aws_ecs_service" "frontend" {
  name          = "${var.env_name}-frontend"
  cluster       = aws_ecs_cluster.default.id
  desired_count = 2

  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100

  task_definition = data.aws_ecs_task_definition.frontend.arn

  load_balancer {
    target_group_arn = "${aws_lb_target_group.frontend.arn}"
    container_name   = "${var.env_name}-frontend"
    container_port   = "80"
  }
}

resource "aws_lb_listener_rule" "frontend" {
  count             = 1
  listener_arn = "${aws_lb_listener.https[0].arn}"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "${aws_lb_target_group.frontend.arn}"
  }

  condition {
    path_pattern {
      values = ["*"]
    }
  }
}
