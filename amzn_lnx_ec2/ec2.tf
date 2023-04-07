data "aws_ami" "amazon-linux-2" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_instance" "test_vm" {

  ami                         = data.aws_ami.amazon-linux-2.id
  associate_public_ip_address = var.public_ip
  instance_type               = var.instance_type
  key_name                    = var.pem_key
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = var.subnet_id
  availability_zone           = var.availability_zone

  tags = {
    Name = "${var.name_tag}"
  }
  
}