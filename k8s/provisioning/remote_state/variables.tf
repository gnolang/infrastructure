variable "bucket" {
  type        = string
  description = "Bucket name where Terraform will remotely push and pull State"
  default     = "terraform-provision-state"
}

variable "dynamodb_table" {
  type        = string
  description = "Table name in DynamoDB where Terraform will lock State"
  default     = "terraform_state"
}

variable "region" {
  type        = string
  description = "AWS region where resources should be provisioned"
}
