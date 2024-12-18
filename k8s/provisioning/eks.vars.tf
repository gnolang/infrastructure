variable "eks_addons" {
  description = "list of addons to be created"
  type = map(object({
    version = string
  }))
  default = {
    "kube-proxy" = {
      version = "v1.31.1-eksbuild.2"
    }
    "vpc-cni" = {
      version = "v1.18.5-eksbuild.1"
    }
    "eks-pod-identity-agent" = {
      version = "v1.3.2-eksbuild.2"
    }
    "coredns" = {
      version = "v1.11.3-eksbuild.1"
    }
  }
}

variable "eks_ng_ami" {
  description = "ami for node group"
  default     = "AL2_x86_64"
}

variable "node_groups" {
  description = "node groups configs"
  type = map(object({
    description     = string
    instance_type   = string
    scaling_min     = number
    scaling_max     = number
    scaling_desired = number
    labels          = optional(map(string))
    taints = optional(list(object({
      key    = string
      value  = string
      effect = string
      }))
    )
  }))
  default = {
    "generic" : {
      description     = "generic nodes"
      instance_type   = "c6i.large"
      scaling_min     = 1
      scaling_max     = 3
      scaling_desired = 1
    },
    "validator" : {
      description     = "validator nodes"
      instance_type   = "c6in.large"
      scaling_min     = 1
      scaling_max     = 3
      scaling_desired = 1
      labels = {
        "reserved" : "validator-node"
      }
      taints = [{
        key    = "type"
        value  = "validator"
        effect = "NO_SCHEDULE"
        }
      ]

    },
  }
}
