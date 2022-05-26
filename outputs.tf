#------------------------------------------------------------------------------
# S3 Bucket
#------------------------------------------------------------------------------
output "s3_bucket_id" {
  description = "Logging S3 Bucket ID"
  value       = aws_s3_bucket.logs.id
}

output "s3_bucket_arn" {
  description = "Logging S3 Bucket ARN"
  value       = aws_s3_bucket.logs.arn
}

output "s3_bucket_domain_name" {
  description = "Logging S3 Bucket Domain Name"
  value       = aws_s3_bucket.logs.bucket_domain_name
}
