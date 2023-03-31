data "template_file" "user_data_v1" {
  template = "${file("${path.module}/ec2_user_data_v1.yaml")}"

  vars = {
    cluster_name = var.ecs_cluster_name
  }
}

# ec2 container instances launch configuration
resource "aws_launch_configuration" "app_v1" {
  count = var.ecs_ami_name != "" ? 1 : 0
  name_prefix   = "${var.env_name}-v1"
  image_id      = data.aws_ami.ecs_optimized.id
  instance_type = var.ec2_instance_type
  iam_instance_profile = aws_iam_instance_profile.ecs_host_instance_profile.name
  user_data     = data.template_file.user_data_v1.rendered
  key_name      = var.instance_key_pair_name
  associate_public_ip_address = lower(var.instance_subnet) == "private" ? false : true
  security_groups = [aws_security_group.egress_anywhere.id,aws_security_group.ssh_ingress.id,aws_security_group.open_internal_communication.id]

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_subnet_ids" "for_use_by_ecs_instances" {
  depends_on = [aws_route_table_association.app_public]
  vpc_id = aws_vpc.app.id
  filter {
    name   = "tag:public_or_private"
    values = [var.instance_subnet]
  }
}

# this is the auto-scaling group for container instances
resource "aws_autoscaling_group" "app_v1" {
  count = var.ecs_ami_name != "" ? 1 : 0
  name_prefix        = "${aws_launch_configuration.app_v1[0].name}-"
  min_size           = 1
  max_size           = 2
  desired_capacity   = 2
  launch_configuration = aws_launch_configuration.app_v1[0].name
  vpc_zone_identifier = data.aws_subnet_ids.for_use_by_instances.ids

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.env_name}-cluster-v1"
    propagate_at_launch = true
  }
}

data "aws_iam_policy_document" "instance-assume-role-policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}
