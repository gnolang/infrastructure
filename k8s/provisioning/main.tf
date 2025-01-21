terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.80"
    }
  }

  backend "s3" {
    dynamodb_table = ""
    bucket  = ""
    key     = ""
    region = ""
    encrypt = true
  }
}

provider "aws" {
  region = var.eks_region
}
