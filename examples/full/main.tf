module "logs_bucket" {
  source = "../../"

  bucket_name         = "test"
  force_destroy       = false
  object_lock_enabled = false
  bucket_versioning = {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }
  bucket_server_side_encryption = {
    sse_algorithm     = "AES256"
    kms_master_key_id = null
  }
  log_delivery_principals = ["cloudtrail.amazonaws.com"]
}
