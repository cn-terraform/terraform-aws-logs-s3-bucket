###########
# S3 bucket
###########
# trivy:ignore:AWS-0089 (LOW): Bucket has logging disabled
resource "aws_s3_bucket" "logs" {
  bucket              = var.bucket_name
  force_destroy       = var.force_destroy
  object_lock_enabled = var.object_lock_enabled
  tags = merge(
    var.tags,
    {
      Name = var.bucket_name
    }
  )
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration {
    status     = var.bucket_versioning.status
    mfa_delete = var.bucket_versioning.mfa_delete
  }
}

# Bucket ownership controls, to enforce bucket owner enforced ownership
resource "aws_s3_bucket_ownership_controls" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# S3 bucket block public access
resource "aws_s3_bucket_public_access_block" "logs" {
  bucket = aws_s3_bucket.logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Server side encryption configuration for the bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.bucket_server_side_encryption.sse_algorithm
      kms_master_key_id = contains(["aws:kms", "aws:kms:dsse"], var.bucket_server_side_encryption.sse_algorithm) ? var.bucket_server_side_encryption.kms_master_key_id : null
    }
  }
}

######################
# Bucket access policy
######################

# Allow the logging services to write and check ACLs (CloudTrail, etc.)
data "aws_iam_policy_document" "allow_log_delivery" {
  statement {
    sid = "AllowLogDeliveryServices"
    principals {
      type        = "Service"
      identifiers = var.log_delivery_principals
    }
    actions = [
      "s3:GetBucketAcl",
      "s3:PutObject"
    ]
    resources = [
      aws_s3_bucket.logs.arn,
      "${aws_s3_bucket.logs.arn}/*"
    ]
  }
}

# Deny any PutObject that does not use an allowed SSE algorithm
data "aws_iam_policy_document" "deny_unencrypted" {
  statement {
    sid    = "DenyUnencryptedUploads"
    effect = "Deny"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/*"]

    condition {
      test     = "StringNotEquals"
      variable = "s3:x-amz-server-side-encryption"
      values   = [var.bucket_server_side_encryption.sse_algorithm]
    }
  }
}

# Combined policy document
data "aws_iam_policy_document" "logs_access_policy_document" {
  source_policy_documents = [
    data.aws_iam_policy_document.allow_log_delivery.json,
    data.aws_iam_policy_document.deny_unencrypted.json
  ]
}

# Policy attached to the bucket
resource "aws_s3_bucket_policy" "logs_access_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_access_policy_document.json
}
