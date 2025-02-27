variable "gno_project" {
  description = "The Gno project the provisioning operation is referring to"
}

variable "eks_cluster_admin_user" {
  description = "reference to the username of the IAM user who will admin the cluster."
}

variable "eks_region" {
  type        = string
  description = "AWS region where resources should be provisioned"
  default     = "eu-west-1"
}

locals {
  cluster_name    = "${var.gno_project}-cluster"
  vpc_name        = "${var.gno_project}-vpc"
  node_group_role = "eks-nodegrouprole"
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
