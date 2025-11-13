variable "environment" {
  description = "Name of environment"
  type        = string
}

variable "app_name" {
  description = "Name of application"
  type        = string
}

variable "app_port" {
  description = "Port listening"
  type        = number
}

variable "vpc_id" {
  description = "ID of VPC"
}

variable "private_subnet_ids" {
  description = "List IDs of private subnet"
  type        = list(string)
}

variable "alb_target_group_arn" {
  description = "ARN of Target Group"
  type        = string
}

variable "alb_security_group_id" {
  description = "ID of Security Group"
  type        = string
}
