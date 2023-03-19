output "public_subnet_id" {
  value       = aws_subnet.subnet_public.id
  description = "The ID of the subnet."
}