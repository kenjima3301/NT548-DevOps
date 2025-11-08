output "subnet_id" {
  description = "The ID of the created subnet"
  value       = aws_subnet.main.id
}

output "security_group_id" {
  description = "The ID of the security group"
  value       = aws_security_group.allow_ssh_http.id
}