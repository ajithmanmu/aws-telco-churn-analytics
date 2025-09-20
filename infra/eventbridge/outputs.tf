output "schedule_name" {
  value       = aws_scheduler_schedule.daily.name
  description = "EventBridge Scheduler name"
}

output "schedule_arn" {
  value       = aws_scheduler_schedule.daily.arn
  description = "EventBridge Scheduler ARN"
}

output "scheduler_role_arn" {
  value       = aws_iam_role.scheduler_glue_invoke.arn
  description = "Role assumed by EventBridge Scheduler"
}
