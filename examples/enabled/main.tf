data "aws_caller_identity" "current" {}

module "logs_bucket" {
  source                                   = "../../"
  name_prefix                              = "test-enabled"
  aws_principals_identifiers               = [data.aws_caller_identity.current.arn]
  block_s3_bucket_public_access            = true
  enable_s3_bucket_server_side_encryption  = true
  s3_bucket_server_side_encryption_key_arn = "aws/s3"
}
