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


resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  count = var.enable_s3_bucket_server_side_encryption ? 1 : 0

  bucket = aws_s3_bucket.logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_bucket_server_side_encryption_sse_algorithm
      kms_master_key_id = var.s3_bucket_server_side_encryption_sse_algorithm == "aws:kms" ? var.s3_bucket_server_side_encryption_key : null
    }
  }
}

#------------------------------------------------------------------------------
# IAM POLICY DOCUMENT - For access logs to the S3 bucket
#------------------------------------------------------------------------------
data "aws_caller_identity" "current" {}

locals {
  aws_principals_identifiers = (
    length(var.aws_principals_identifiers) == 0
    ? [data.aws_caller_identity.current.account_id]
    : var.aws_principals_identifiers
  )
}

data "aws_iam_policy_document" "logs_access_policy_document" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = local.aws_principals_identifiers
    }
    actions   = ["s3:PutObject"]
    resources = ["${aws_s3_bucket.logs.arn}/*", ]
  }
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logdelivery.elb.amazonaws.com"]
    }
    actions   = ["s3:GetBucketAcl"]
    resources = [aws_s3_bucket.logs.arn]
  }

  statement {
    sid = "https-only"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    effect = "Deny"

    actions = [
      "s3:*",
    ]

    resources = [
      "arn:aws:s3:::${aws_s3_bucket.logs.id}",
      "arn:aws:s3:::${aws_s3_bucket.logs.id}/*",
    ]

    condition {
      test     = "Bool"
      variable = "aws:SecureTransport"
      values   = [false]
    }
  }
}

#------------------------------------------------------------------------------
# IAM POLICY - For access logs to the s3 bucket
#------------------------------------------------------------------------------
resource "aws_s3_bucket_policy" "logs_access_policy" {
  bucket = aws_s3_bucket.logs.id
  policy = data.aws_iam_policy_document.logs_access_policy_document.json
}
