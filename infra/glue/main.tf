# Glue Workflow
resource "aws_glue_workflow" "this" {
  name                 = var.workflow_name
  description          = "Daily pipeline: CSV -> Parquet, then crawl processed data."
  max_concurrent_runs  = 1
}

# Trigger 1: kick off job when workflow starts
resource "aws_glue_trigger" "start_job" {
  name          = "${var.workflow_name}-start-job"
  type          = "ON_DEMAND"          # fired by workflow start
  workflow_name = aws_glue_workflow.this.name

  actions {
    job_name = var.glue_job_name
  }
}

# Trigger 2: after job succeeds, run the crawler
resource "aws_glue_trigger" "crawl_after_job" {
  name          = "${var.workflow_name}-crawl-after-job"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.this.name

  predicate {
    conditions {
      job_name = var.glue_job_name
      state    = "SUCCEEDED"
    }
  }

  actions {
    crawler_name = var.glue_crawler_name
  }
}
