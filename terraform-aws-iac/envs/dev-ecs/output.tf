output "application_url" {
  description = "URL to access web"
  value       = "http://${module.alb.alb_dns_name}"
}

output "ecr_repository_url" {
  description = "URL of ECR (for Github Action push image)"
  value       = module.ecs.ecr_repository_url
}
