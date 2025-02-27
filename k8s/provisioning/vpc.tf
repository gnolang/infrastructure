# Create VPC for EKS Cluster
module "vpc_for_eks" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = local.vpc_name
  cidr = "10.0.0.0/16"

  azs             = ["${var.eks_region}a", "${var.eks_region}b"]
  public_subnets  = ["10.0.0.0/24", "10.0.1.0/24"]
  private_subnets = ["10.0.10.0/24", "10.0.11.0/24"]

  enable_nat_gateway      = false
  single_nat_gateway      = false
  enable_dns_hostnames    = true
  map_public_ip_on_launch = true # Explicitly set "auto-assign public IP"
}
