resource "aws_security_group" "eks_sg" {
  name        = "eks-${var.gno_project}-sg"
  description = "Sec group for ${var.gno_project} EKS cluster"
  vpc_id      = module.vpc_for_eks.vpc_id

  tags = {
    Project = var.gno_project
  }
}

resource "aws_vpc_security_group_ingress_rule" "_ingress_ipv4" {
  security_group_id = aws_security_group.eks_sg.id
  ip_protocol       = "tcp"
  description       = each.value.description
  from_port         = each.value.port
  to_port           = each.value.port
  cidr_ipv4         = "0.0.0.0/0"
  for_each          = var.vpc_sg_inbound_ports

}

resource "aws_vpc_security_group_egress_rule" "outbound_all_traffic_ipv4" {
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}

resource "aws_vpc_security_group_egress_rule" "outbound_all_traffic_ipv6" {
  security_group_id = aws_security_group.eks_sg.id
  cidr_ipv6         = "::/0"
  ip_protocol       = "-1"
}
