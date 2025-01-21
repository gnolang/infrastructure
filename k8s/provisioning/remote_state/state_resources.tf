terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.80"
    }
  }
}

provider "aws" {
  region = var.region
}

##########################
### TF state resources ###
##########################

resource "aws_s3_bucket" "state_s3_bucket" {
  bucket = var.bucket
}

resource "aws_s3_bucket_versioning" "versioning_bucket" {
  bucket = aws_s3_bucket.state_s3_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encryption_bucket" {
  bucket = aws_s3_bucket.state_s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "state_dynamo_db" {
  name           = var.dynamodb_table
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"
  read_capacity  = 1
  write_capacity = 1

  attribute {
    name = "LockID"
    type = "S"
  }
}
