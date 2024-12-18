data "aws_iam_role" "eks_cluster_role" {
  name = "eksTestClusterRole"
}

resource "aws_eks_cluster" "eks_gno" {
  name = local.cluster_name

  access_config {
    authentication_mode = "API"
  }

  role_arn = data.aws_iam_role.eks_cluster_role.arn
  version  = "1.31"

  enabled_cluster_log_types = ["scheduler", "controllerManager"]

  vpc_config {
    subnet_ids         = toset(data.aws_subnets.all_vpc_subnets.ids)
    security_group_ids = [aws_security_group.eks_sg.id]
  }

}

# Addons
resource "aws_eks_addon" "addons" {
  for_each = var.eks_addons

  cluster_name                = aws_eks_cluster.eks_gno.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_update = "PRESERVE"
}

# Node groups
data "aws_iam_role" "eks_node_group_role" {
  name = "eks-nodegrouprole"
}

resource "aws_eks_node_group" "eks_nodes" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.eks_gno.name
  node_group_name = "${var.gno_project}-ng-${each.key}"
  node_role_arn   = data.aws_iam_role.eks_node_group_role.arn
  subnet_ids      = local.public_subnets

  scaling_config {
    min_size     = each.value.scaling_min
    max_size     = each.value.scaling_max
    desired_size = each.value.scaling_desired
  }

  update_config {
    max_unavailable = 1
  }
  ami_type       = var.eks_ng_ami
  instance_types = [each.value.instance_type]
  disk_size      = 20

  labels = each.value.labels

  # Dynamically add taints if they exist
  dynamic "taint" {
    for_each = each.value.taints != null ? each.value.taints : []

    content {
      key    = taint.value.key
      value  = taint.value.value
      effect = taint.value.effect
    }
  }
}

output "eks_cluster_id" {
  description = "Generated Cluster id"
  value       = aws_eks_cluster.eks_gno.id
}

output "kube-config" {
  description = "command to update kube context to newly created cluster"
  value = <<EOT
Please switch Kube Context to the cluster just created
AWS_PROFILE=<optional_AWS_profile> aws eks update-kubeconfig --region ${var.region} --name ${aws_eks_cluster.eks_gno.name}
  EOT
}
