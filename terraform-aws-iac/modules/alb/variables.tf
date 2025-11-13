variable "environment" {
  description = "Name of environment (Ex: dev, staging, prod,...)"
  type        = string
}

variable "vpc_id" {
  description = "ID of VPC that ALB in"
  type        = string
}

variable "public_subnet_ids" {
  description = "List ID of Public subnet"
  type        = list(string)
}

variable "app_port" {
  description = "Port that Fargate is listening (Ex: 80, 8080,...)"
  type        = number
}
