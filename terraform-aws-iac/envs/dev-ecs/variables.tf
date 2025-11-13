variable "environment" {
  description = "Name of environment"
  type        = string
  default     = "dev-ecs"
}

variable "app_port" {
  description = "Port listening"
  type        = number
}

variable "app_name" {
  description = "Name of application"
  type        = string
}

variable "aws_region" {
  description = "Region of AWS"
  type        = string
  default     = "ap-southeast-1"
}

variable "vpc_cidr" {
  description = "IP of VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "IP of Public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "IP of Private subnet"
  type        = string
}

