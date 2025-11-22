variable "environment" {
  description = "Name of environment"
  type        = string
}
variable "instance_type" {
  description = "EC2 Type"
  type        = string
}

variable "ami_id" {
  description = "AMI type for EC2"
  type        = string
}

variable "aws_region" {
  description = "Region of AWS"
  type        = string
}

variable "vpc_cidr" {
  description = "IP of VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "IP for Public subnet"
  type        = string
}

variable "private_subnet_cidr" {
  description = "IP for Private subnet"
  type        = string
}
