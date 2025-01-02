variable "gno_project" {
  description = "The Gno project the provisioning operation is referring to"
}

# variable "gno_aws_profile" {
#   description = "AWS profile to be used (optional)"
# }

variable "region" {
  type        = string
  description = "AWS region where resources should be provisioned"
  default     = "eu-west-3"
}

variable "vpc_id" {
  type        = string
  description = "VPC ehre cluster will be deployed in"
  default     = "vpc-0b8f7e6c751800463"
}

locals {
  cluster_name = "${var.gno_project}-cluster"
}

variable "vpc_sg_inbound_ports" {
  description = "list of inbound ports"
  type = map(object({
    port        = number
    description = string
  }))
  default = {
    "http" : {
      port        = 80
      description = "HTTP"
    },
    "https" : {
      port        = 443
      description = "HTTPS"
    },
    "gno-p2p" : {
      port        = 26656
      description = "Gnoland P2P"
    },
  }
}
