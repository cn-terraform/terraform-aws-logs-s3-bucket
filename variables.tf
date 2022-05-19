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
# AWS REGION
#------------------------------------------------------------------------------
variable "region" {
  type        = string
  description = "AWS Region the infrastructure is hosted in"
}

#------------------------------------------------------------------------------
# IAM
#------------------------------------------------------------------------------
variable "aws_principals_identifiers" {
  type        = list(string)
  description = "List of identifiers for AWS principals with access to write in the logs bucket"
}

#------------------------------------------------------------------------------
# S3
#------------------------------------------------------------------------------
variable "enable_s3_bucket_server_side_encryption" {
  description = "(Optional) If true, server side encryption will be applied."
  type        = bool
  default     = false
}
