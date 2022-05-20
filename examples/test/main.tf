module "logs_bucket" {
  source = "../../"

  name_prefix                                    = "test"
  aws_principals_identifiers                     = ["test-user-arn"]
  block_s3_bucket_public_access                  = true
  enable_s3_bucket_server_side_encryption        = true
  s3_bucket_server_side_encryption_sse_algorithm = "aws:kms"
  s3_bucket_server_side_encryption_key           = "aws/s3"
}
