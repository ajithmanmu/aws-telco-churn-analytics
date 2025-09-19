variable "project" {
  type    = string
  default = "telco-churn"
}

variable "env" {
  type    = string
  default = "dev"
}

variable "region" {
  type    = string
  default = "us-east-1"
}

# Buckets from your s3 stack (hardcode for now or pass via -var)
variable "raw_bucket" {
  type    = string
  default = "telco-churn-dev-churn-raw"
}

variable "processed_bucket" {
  type    = string
  default = "telco-churn-dev-churn-processed"
}
