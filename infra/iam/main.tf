locals {
  name_prefix = "${var.project}-${var.env}"
  logs_arn    = "arn:aws:logs:${var.region}:*:log-group:/aws-glue/*"
}

# ---------- Glue Crawler Role ----------
data "aws_iam_policy_document" "glue_crawler_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_crawler_role" {
  name               = "${local.name_prefix}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_trust.json
}

# Crawler permissions: read both buckets, update catalog, write logs
data "aws_iam_policy_document" "glue_crawler_policy" {
  statement { # S3 list prefixes
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.raw_bucket}",
      "arn:aws:s3:::${var.processed_bucket}"
    ]
  }

  statement { # S3 get objects from raw/processed
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.raw_bucket}/*",
      "arn:aws:s3:::${var.processed_bucket}/*"
    ]
  }

  statement { # Glue catalog (narrow but functional)
    actions = [
      "glue:GetDatabase", "glue:GetDatabases",
      "glue:CreateTable", "glue:UpdateTable", "glue:DeleteTable",
      "glue:GetTable", "glue:GetTables",
      "glue:GetPartition", "glue:GetPartitions",
      "glue:CreatePartition", "glue:UpdatePartition", "glue:DeletePartition",
      "glue:BatchGetPartition", "glue:BatchCreatePartition","glue:BatchUpdatePartition"
    ]
    resources = ["*"]
  }

  statement { # CloudWatch Logs
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [local.logs_arn, "${local.logs_arn}:*"]
  }
}

resource "aws_iam_policy" "glue_crawler_policy" {
  name   = "${local.name_prefix}-glue-crawler-policy"
  policy = data.aws_iam_policy_document.glue_crawler_policy.json
}

resource "aws_iam_role_policy_attachment" "glue_crawler_attach" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

# ---------- Glue Job Role ----------
data "aws_iam_policy_document" "glue_job_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_job_role" {
  name               = "${local.name_prefix}-glue-job-role"
  assume_role_policy = data.aws_iam_policy_document.glue_job_trust.json
}

data "aws_iam_policy_document" "glue_job_policy" {
  statement { # list buckets
    actions = ["s3:ListBucket"]
    resources = [
      "arn:aws:s3:::${var.raw_bucket}",
      "arn:aws:s3:::${var.processed_bucket}"
    ]
  }

  statement { # read raw objects
    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.raw_bucket}/*"]
  }

  statement { # allow Glue to read the job script in processed bucket
    actions = ["s3:GetObject"]
    resources = [
      "arn:aws:s3:::${var.processed_bucket}/*"
    ]
  }

  statement { # write processed objects
    actions   = ["s3:PutObject", "s3:AbortMultipartUpload", "s3:ListBucketMultipartUploads"]
    resources = ["arn:aws:s3:::${var.processed_bucket}/*"]
  }

  statement { # Glue catalog access
    actions = [
      "glue:GetDatabase", "glue:GetDatabases", "glue:GetTable", "glue:GetTables",
      "glue:GetPartition", "glue:GetPartitions", "glue:CreateTable", "glue:UpdateTable"
    ]
    resources = ["*"]
  }

  statement { # CloudWatch Logs
    actions   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
    resources = [local.logs_arn, "${local.logs_arn}:*"]
  }
}

resource "aws_iam_policy" "glue_job_policy" {
  name   = "${local.name_prefix}-glue-job-policy"
  policy = data.aws_iam_policy_document.glue_job_policy.json
}

resource "aws_iam_role_policy_attachment" "glue_job_attach" {
  role       = aws_iam_role.glue_job_role.name
  policy_arn = aws_iam_policy.glue_job_policy.arn
}
