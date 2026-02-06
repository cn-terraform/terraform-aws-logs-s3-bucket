######
# Misc
######
variable "tags" {
  type        = map(string)
  default     = {}
  description = "Resource tags"
}

###########
# S3 bucket
###########
variable "bucket_name" {
  type        = string
  description = "Name prefix for resources on AWS"
}

variable "force_destroy" {
  description = "(Optional, Default:false) Boolean that indicates all objects (including any locked objects) should be deleted from the bucket when the bucket is destroyed so that the bucket can be destroyed without error. These objects are not recoverable. This only deletes objects when the bucket is destroyed, not when setting this parameter to true. Once this parameter is set to true, there must be a successful terraform apply run before a destroy is required to update this value in the resource state. Without a successful terraform apply after this parameter is set, this flag will have no effect. If setting this field in the same operation that would require replacing the bucket or destroying the bucket, this flag will not work. Additionally when importing a bucket, a successful terraform apply is required to set this value in state before it will take effect on a destroy operation."
  type        = bool
  default     = false
}

variable "object_lock_enabled" {
  description = "(Optional, Forces new resource) Indicates whether this bucket has an Object Lock configuration enabled. Valid values are true or false. This argument is not supported in all regions or partitions."
  type        = bool
  default     = false
}

variable "bucket_versioning" {
  description = "value"
  type = object({
    status     = string
    mfa_delete = optional(string)
  })
  default = {
    status     = "Enabled"
    mfa_delete = "Enabled"
  }

  validation {
    condition     = contains(["Enabled", "Suspended", "Disabled"], var.bucket_versioning.status)
    error_message = "The value of var.bucket_versioning.status must be one of Enabled, Suspended, or Disabled."
  }

  validation {
    condition     = contains(["Enabled", "Disabled"], var.bucket_versioning.mfa_delete)
    error_message = "The value of var.bucket_versioning.mfa_delete must be one of Enabled or Disabled."
  }
}

variable "bucket_server_side_encryption" {
  description = "(Optional) The bucket server side encryption configuration."
  type = object({
    sse_algorithm     = string
    kms_master_key_id = optional(string)
  })
  default = {
    sse_algorithm     = "AES256"
    kms_master_key_id = null
  }

  validation {
    condition     = contains(["AES256", "aws:kms", "aws:kms:dsse"], var.bucket_server_side_encryption.sse_algorithm)
    error_message = "The value of var.bucket_server_side_encryption.sse_algorithm must be one of AES256, aws:kms, or aws:kms:dsse."
  }
}

######################
# Bucket access policy
######################
variable "log_delivery_principals" {
  type        = list(string)
  description = "Service principals allowed to deliver logs. Example: [\"cloudtrail.amazonaws.com\"]. Add ELB, vpc-flow-logs principals as needed."

  validation {
    condition     = length(var.log_delivery_principals) >= 1
    error_message = "At least one log delivery principal should be set"
  }
}
