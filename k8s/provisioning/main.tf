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

data "aws_vpc" "vpc_cluster" {
  id = var.vpc_id
}

# VPC Subnets
data "aws_subnets" "all_vpc_subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_cluster.id]
  }
}

# VPC Route Tables
data "aws_route_tables" "all_vpc_rt" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc_cluster.id]
  }
}

data "aws_route_table" "public_vpc_rt" {
  for_each       = toset(data.aws_route_tables.all_vpc_rt.ids)
  route_table_id = each.value
}

## Route Tables with an Internet-Gateway
locals {
  igw_route_tables = [
    for rt in data.aws_route_table.public_vpc_rt : rt
    if length([
      for route in rt.routes : route
      if route.gateway_id != null && startswith(route.gateway_id, "igw-")
    ]) > 0
  ]
}

# Filter public subnets based on RT having an Internet Gateway
locals {
  public_subnets = [
    for subnet_id in data.aws_subnets.all_vpc_subnets.ids : subnet_id
    if length([
      // TODO: supposing ONLY one Route Table with IGW
      for association in local.igw_route_tables[0].associations : association
      if association.subnet_id == subnet_id
    ]) > 0
  ]
}
