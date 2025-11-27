variable "environment" {
  description = "Name of environment"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of Public Subnet IDs"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  type        = list(string)
}
