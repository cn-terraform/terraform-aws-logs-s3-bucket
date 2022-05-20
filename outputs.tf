#------------------------------------------------------------------------------
# S3 Bucket
#------------------------------------------------------------------------------
output "lb_logs_s3_bucket_id" {
  description = "LB Logging S3 Bucket ID"
  value       = aws_s3_bucket.logs.id
}

output "lb_logs_s3_bucket_arn" {
  description = "LB Logging S3 Bucket ARN"
  value       = aws_s3_bucket.logs.arn
}
