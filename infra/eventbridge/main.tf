data "aws_caller_identity" "current" {}

locals {
  workflow_name = var.glue_workflow_name
}

# IAM role assumed by EventBridge Scheduler
resource "aws_iam_role" "scheduler_glue_invoke" {
  name = "telco-scheduler-glue-invoke-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "scheduler.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

# Policy: allow StartWorkflowRun on the workflow
resource "aws_iam_role_policy" "scheduler_glue_invoke" {
  name = "telco-scheduler-glue-invoke-policy"
  role = aws_iam_role.scheduler_glue_invoke.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["glue:StartWorkflowRun"],
      Resource = "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:workflow/${local.workflow_name}"
    }]
  })
}

# EventBridge Scheduler: start the Glue workflow on a schedule
resource "aws_scheduler_schedule" "daily" {
  name                = var.schedule_name
  description         = "Daily start of Glue workflow ${local.workflow_name}"
  schedule_expression = var.schedule_expression

  flexible_time_window { mode = "OFF" }

  target {
    arn      = "arn:aws:scheduler:::aws-sdk:glue:startWorkflowRun"
    role_arn = aws_iam_role.scheduler_glue_invoke.arn

    # AWS SDK target input to StartWorkflowRun
    input = jsonencode({
      Name = local.workflow_name
    })
  }
}
