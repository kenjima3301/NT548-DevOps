# output "web_server_public_ip" {
#   description = "Public IP of the web server in dev"
#   value       = module.ec2.public_ip
# }

output "ecr_repository_url" {
  description = "URL of ECR store to push image"
  value       = aws_ecr_repository.my_app.repository_url
}

output "media_bucket_name" {
  description = "Name of S3 Bucket media"
  value       = module.s3_media.bucket_name
}
