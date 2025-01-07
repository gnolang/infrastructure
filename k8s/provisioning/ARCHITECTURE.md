# Infra architecture

## VPC

- 2 Subnets public - Auto assign IPv4 address
- 2 Subnets private
- IGW: Internet Gateway
- S3 VPC Endpoint

## EKS Cluster

- Cluster Role: `eksTestClusterRole`
- Cluster security group
- Observability
  - Controller
  - Scheduler
- AddOns
  - Kube-proxy
  - CoreDNS
  - Amazon VPC CNI
  - Amazon EKS Pod Identity Agent

## Node Groups

### Commons

- Role -> `eks-nodegrouprole`
- AMI -> `Amazon Linux2`
- Instance type -> On-demand + `c6in.large`
- Storage: 20GB - `gp3`
- Node group update configuration -> Maximum unavailable: 30%
- Subnets -> VPC public networks

### Generics

- Nodes (desired/min/max) 3/2/4

### Validators

- Nodes (desired/min/max) 10/3/12
- Labels -> `reserved=validator-node`
- Taints -> `type=validator:NoSchedule`
- Remote Access (TODO:)

## TODO

- EBS storage
- AWS native backups on EBS
