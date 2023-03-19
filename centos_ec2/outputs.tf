output "id" {
  description = "The ID of the instance"
  value       = aws_instance.test_vm.id
}

output "public_dns" {
  description = "The public DNS name assigned to the instance. For EC2-VPC, this is only available if you've enabled DNS hostnames for your VPC"
  value       = aws_instance.test_vm.public_dns
}

output "public_ip" {
  description = "The public IP address assigned to the instance, if applicable. NOTE: If you are using an aws_eip with your instance, you should refer to the EIP's address directly and not use `public_ip` as this field will change after the EIP is attached"
  value       = aws_instance.test_vm.associate_public_ip_address
}

output "private_ip" {
  description = "The private IP address assigned to the instance."
  value       = aws_instance.test_vm.private_ip
}