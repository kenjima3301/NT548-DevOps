output "alb_target_group_arn" {
  description = "ARN of target group"
  value       = aws_lb_target_group.main.arn
}

output "alb_dns_name" {
  description = "DNS name of ALB"
  value       = aws_lb.main.dns_name
}

output "alb_security_group_id" {
  description = "ID of Security Group"
  value       = aws_security_group.alb_sg.id
}
