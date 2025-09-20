variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "schedule_name" {
  description = "EventBridge Scheduler name"
  type        = string
  default     = "telco-daily-workflow-schedule"
}

variable "schedule_expression" {
  description = "Cron/at expression for EventBridge Scheduler (UTC)"
  type        = string
  default     = "cron(0 1 * * ? *)" # daily at 01:00 UTC
}

variable "glue_workflow_name" {
  description = "Target Glue workflow to start"
  type        = string
  default     = "telco-daily-workflow"
}
