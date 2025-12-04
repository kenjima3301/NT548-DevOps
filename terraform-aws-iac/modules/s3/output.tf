output "bucket_name" {
  description = "Name of Bucket"
  value       = aws_s3_bucket.this.id
}

output "bucket_region" {
  description = "Region của Bucket"
  value       = aws_s3_bucket.this.region
}

output "bucket_arn" {
  description = "ARN của Bucket"
  value       = aws_s3_bucket.this.arn
}
