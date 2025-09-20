variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "workflow_name" {
  description = "Glue workflow name"
  type        = string
  default     = "telco-daily-workflow"
}

variable "glue_job_name" {
  description = "Existing Glue ETL job name"
  type        = string
  default     = "telco-csv-to-parquet"
}

variable "glue_crawler_name" {
  description = "Existing Glue crawler name for processed data"
  type        = string
  default     = "telco-processed-crawler"
}
