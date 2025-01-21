data "aws_iam_role" "eks_cluster_role" {
  name = "eksTestClusterRole"
}

data "aws_iam_user" "eks_admin_role" {
  user_name = var.eks_cluster_admin_user
}

resource "aws_eks_cluster" "eks_gno" {
  name     = local.cluster_name
  version  = "1.31"
  role_arn = data.aws_iam_role.eks_cluster_role.arn

  access_config {
    authentication_mode = "API"
    # adds the current caller identity as an administrator
    # bootstrap_cluster_creator_admin_permissions = true
  }

  enabled_cluster_log_types = ["scheduler", "controllerManager"]
  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids              = toset(concat(module.vpc_for_eks.public_subnets, module.vpc_for_eks.private_subnets))
    security_group_ids      = [aws_security_group.eks_sg.id]
    endpoint_public_access  = true
    endpoint_private_access = true
  }

  depends_on = [module.vpc_for_eks]
}

resource "aws_eks_access_entry" "access_entry" {
  cluster_name  = aws_eks_cluster.eks_gno.name
  principal_arn = data.aws_iam_user.eks_admin_role.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "access_policy" {
  cluster_name  = aws_eks_cluster.eks_gno.name
  principal_arn = data.aws_iam_user.eks_admin_role.arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

# Addons
resource "aws_eks_addon" "addons" {
  for_each = var.eks_addons

  cluster_name                = aws_eks_cluster.eks_gno.name
  addon_name                  = each.key
  addon_version               = each.value.version
  resolve_conflicts_on_update = "PRESERVE"

  # Note: this is needed especially for CoreDNS add-on
  depends_on = [aws_eks_node_group.eks_nodes]
}

# Node groups
data "aws_iam_role" "eks_node_group_role" {
  name = local.node_group_role
}

resource "aws_eks_node_group" "eks_nodes" {
  for_each        = var.node_groups
  cluster_name    = aws_eks_cluster.eks_gno.name
  node_group_name = "${var.gno_project}-ng-${each.key}"
  node_role_arn   = data.aws_iam_role.eks_node_group_role.arn
  subnet_ids      = module.vpc_for_eks.public_subnets

  scaling_config {
    desired_size = each.value.scaling_desired
    min_size     = each.value.scaling_min
    max_size     = each.value.scaling_max
  }

  update_config {
    max_unavailable_percentage = each.value.max_unavailable
  }
  ami_type       = var.eks_ng_ami
  instance_types = [each.value.instance_type]
  capacity_type  = "ON_DEMAND"
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

  # Allow external changes without Terraform plan difference
  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
  depends_on = [aws_eks_access_policy_association.access_policy]
}

output "eks_cluster_id" {
  description = "Generated Cluster id"
  value       = aws_eks_cluster.eks_gno.id
}

output "kube-config" {
  description = "command to update kube context to newly created cluster"
  value       = <<EOT
Please switch Kube Context to the cluster just created
AWS_PROFILE=<optional_AWS_profile> aws eks update-kubeconfig --region ${var.eks_region} --name ${aws_eks_cluster.eks_gno.name}
  EOT
}
