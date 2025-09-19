locals {
  raw_bucket       = "${var.project}-${var.env}-churn-raw"
  processed_bucket = "${var.project}-${var.env}-churn-processed"
  athena_bucket    = "${var.project}-${var.env}-athena-results"
  buckets          = toset([local.raw_bucket, local.processed_bucket, local.athena_bucket])
}

resource "aws_s3_bucket" "b" {
  for_each = local.buckets
  bucket   = each.value
  tags     = { Project = var.project, Env = var.env }
}

# Public Access Block (PAB): prevents accidental public exposure via ACLs/policies
resource "aws_s3_bucket_public_access_block" "b" {
  for_each                = aws_s3_bucket.b
  bucket                  = each.value.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
}

# Bucket owner enforced (no ACLs)
resource "aws_s3_bucket_ownership_controls" "b" {
  for_each = aws_s3_bucket.b
  bucket   = each.value.id
  rule { object_ownership = "BucketOwnerEnforced" }
}

# Default encryption (SSE-S3 by default; KMS optional)
resource "aws_s3_bucket_server_side_encryption_configuration" "b" {
  for_each = aws_s3_bucket.b
  bucket   = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.use_kms ? "aws:kms" : "AES256"
      kms_master_key_id = var.use_kms ? var.kms_key_arn : null
    }
    bucket_key_enabled = var.use_kms
  }
}
