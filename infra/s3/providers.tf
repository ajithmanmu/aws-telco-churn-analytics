terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }
  backend "local" {} # simple now; you can switch to S3/Dynamo later if needed
}

provider "aws" {
  region = var.region
}
