resource "aws_security_group" "sg" {
  name        = "EC2 SSH SG - Home"
  description = "Security Group for SSH"
  vpc_id      =  var.vpc_id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.my_public_ip]
}
}