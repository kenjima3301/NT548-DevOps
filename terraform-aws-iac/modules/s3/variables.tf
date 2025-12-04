variable "bucket_name" {
  description = "Unique name of S3 Bucket"
  type        = string
}

variable "environment" {
  description = "Name of environment"
  type        = string
  default     = "dev"
}
