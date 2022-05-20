#------------------------------------------------------------------------------
# Misc
#------------------------------------------------------------------------------
variable "name_prefix" {
  type        = string
  description = "Name prefix for resources on AWS"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------
variable "aws_principals_identifiers" {
  type        = list(string)
  description = "List of identifiers for AWS principals with access to write in the logs bucket"
}

#------------------------------------------------------------------------------
# S3 bucket
#------------------------------------------------------------------------------
variable "block_s3_bucket_public_access" {
  description = "(Optional) If true, public access to the S3 bucket will be blocked."
  type        = bool
  default     = true
}

variable "enable_s3_bucket_server_side_encryption" {
  description = "(Optional) If true, server side encryption will be applied."
  type        = bool
  default     = true
}

variable "s3_bucket_server_side_encryption_key_arn" {
  description = "(Optional) Allows the SSE key to use a Customer Managed Key, defaults to the alias and AWS managed key."
  type        = string
  default     = "aws/s3"
}
