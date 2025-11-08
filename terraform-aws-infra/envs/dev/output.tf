output "web_server_public_ip" {
  description = "Public IP of the web server in dev"
  value       = module.ec2.public_ip
}
