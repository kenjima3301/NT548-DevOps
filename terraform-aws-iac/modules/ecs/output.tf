output "ecr_repository_url" {
  description = "URL of ECR repository"
  value       = aws_ecr_repository.main.repository_url
}
