output "glue_workflow_name" {
  value       = aws_glue_workflow.this.name
  description = "Glue workflow name"
}

output "glue_workflow_arn" {
  value       = aws_glue_workflow.this.arn
  description = "Glue workflow ARN"
}
