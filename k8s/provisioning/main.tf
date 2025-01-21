terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.80"
    }
  }

  # backend "s3" {
  #   # dynamodb_table = ""
  #   bucket  = ""
  #   key     = ""
  #   encrypt = true
  #   # region = ""
  # }
}

provider "aws" {
  region = var.eks_region
}
