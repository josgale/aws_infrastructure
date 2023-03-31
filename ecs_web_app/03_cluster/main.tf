provider "aws" {
  region                        =       var.aws_region
  profile                       =       var.profile
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

data "aws_subnet_ids" "for_use_by_instances" {
  depends_on = [aws_route_table_association.app_public]
  vpc_id = aws_vpc.app.id
  filter {
    name   = "tag:public_or_private"
    values = [var.instance_subnet]
  }
}
