# variables.tf

variable "s3_bucket" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
}

variable "dynamodb_table" {
  description = "The name of the DynamoDB table for state locking"
  type        = string
}

variable "region" {
  description = "The AWS region where the S3 bucket and DynamoDB table will be created"
  type        = string
}
