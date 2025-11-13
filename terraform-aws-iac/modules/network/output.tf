output "vpc_id" {
  description = "The ID of VPC"
  value       = aws_vpc.main.id
}
output "public_subnet_ids" {
  description = "The IDs of the created public subnet"
  value       = [aws_subnet.public_subnet.id]
}

output "private_subnet_ids" {
  description = "The IDs of the created private subnet"
  value       = [aws_subnet.private_subnet.id]
}

