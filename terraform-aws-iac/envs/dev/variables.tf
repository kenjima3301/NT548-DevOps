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

variable "public_subnet_1_cidr" {
  description = "CIDR Public subnet 1"
  type        = string
}

variable "public_subnet_2_cidr" {
  description = "CIDR Public subnet 2"
  type        = string
}

variable "private_subnet_cidr" {
  description = "IP for Private subnet"
  type        = string
}

variable "app_s3_access_key" {
  description = "Access Key for Web App to access S3"
  type        = string
  sensitive   = true
}

variable "app_s3_secret_key" {
  description = "Secret Key for Web App to access S3"
  type        = string
  sensitive   = true
}
