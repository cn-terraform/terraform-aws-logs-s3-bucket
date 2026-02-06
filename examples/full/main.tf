module "logs_bucket" {
  source = "../../"

  bucket_name         = "test"
  force_destroy       = false
  object_lock_enabled = false
  bucket_versioning = {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
  aws_principals_identifiers                     = ["test-user-arn"]
  enable_s3_bucket_server_side_encryption        = true
  s3_bucket_server_side_encryption_sse_algorithm = "AES256"
}
