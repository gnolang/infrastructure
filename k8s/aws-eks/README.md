# AWS EKS

## Setup

1. Create VPC
2. Create EKS cluster (+ EKS-cluster role)
3. Create EKS Kube context (AWS CLI)
4. Create node group + [role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html)
  AmazonEKSWorkerNodePolicy
  AmazonEC2ContainerRegistryReadOnly
  AmazonEKS_CNI_Policy
5. add EBS CSI storage class

  ```bash
  kubectl apply -k aws-eks/storage/csi
  kubectl apply -f aws-eks/storage/storage-class
  ```

* Security Group
* NLB vs ALB ?
  * [Network Load Balancer - AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/service/nlb/)
