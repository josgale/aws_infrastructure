resource "aws_lb" "lb" {
  name               = var.env_name
  internal           = false
  load_balancer_type = "application"
  subnets            = aws_subnet.app_public.*.id
  security_groups    = [aws_security_group.web.id]
  enable_cross_zone_load_balancing = true

  tags = {
    Name = var.env_name
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https" {
  count             = 1
  load_balancer_arn = aws_lb.lb.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.cert.arn

  default_action {
    type             = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "Fixed response content"
      status_code  = "200"
    }
  }
}

resource "aws_lb_listener_certificate" "cert_wildcard" {
  listener_arn    = aws_lb_listener.https[0].arn
  certificate_arn = data.aws_acm_certificate.cert.arn
}


resource "aws_security_group" "web" {
  name        = "${var.env_name}-allow_http"
  description = "Allow HTTP traffic"
  vpc_id      = "${aws_vpc.app.id}"
}

resource "aws_security_group_rule" "https_ingress" {
  type            = "ingress"
  from_port       = 443
  to_port         = 443
  protocol        = "6"
  cidr_blocks     = var.lb_ingress_sources

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "http_ingress" {
  type            = "ingress"
  from_port       = 80
  to_port         = 80
  protocol        = "6"
  cidr_blocks     = var.lb_ingress_sources

  security_group_id = aws_security_group.web.id
}

resource "aws_security_group_rule" "http_egress" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]

  security_group_id = aws_security_group.web.id
}
