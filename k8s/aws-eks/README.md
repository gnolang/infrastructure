# AWS EKS

## Setup

1. Create VPC
2. Create EKS cluster (+ EKS-cluster role)
3. Create EKS Kube context (AWS CLI)
4. Create node group + [role](https://docs.aws.amazon.com/eks/latest/userguide/create-node-role.html)
  AmazonEKSWorkerNodePolicy
  AmazonEC2ContainerRegistryReadOnly
  AmazonEKS_CNI_Policy
  AmazonEBSCSIDriverPolicy
5. add EBS CSI storage class

  ```bash
  kubectl apply -k aws-eks/storage/csi
  kubectl apply -f aws-eks/storage/storage-class
  ```

* Security Group
* NLB vs ALB
  * [AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/)
  * [Network Load Balancer - AWS Load Balancer Controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.6/guide/service/nlb/)
  * [Route internet traffic with AWS Load Balancer Controller - Amazon EKS](https://docs.aws.amazon.com/eks/latest/userguide/aws-load-balancer-controller.html)

* Generic reference
  * [AWS EKS Elastic Kubernetes Service - STACKSIMPLIFY](https://www.stacksimplify.com/aws-eks/)

## Storage

* High performance

> Local Volume Static Provisioner CSI driver using Amazon EKS managed node groups and pre-bootstrap commands to expose the NVMe EC2 instance store drives as Kubernetes PV objects. This allows leveraging the local NVMe storage volumes to achieve higher performance than what’s possible from the general-purpose Amazon EBS boot volume.

* [EKS Persistent Volumes for Instance Store | Containers](https://aws.amazon.com/blogs/containers/eks-persistent-volumes-for-instance-store/)

* General purpose EBS Disks

  * Using `Container Storage Interface (CSI)`
  * Support dynamic provisioning, no need to create a PV beforehand
  > the Pod will only see a PVC object. All the underlying logic dealing with the actual storage technology is implemented by the provisioner the Storage Class object uses.

* [Persistent storage for Kubernetes | AWS Storage Blog](https://aws.amazon.com/blogs/storage/persistent-storage-for-kubernetes/)

### Size

Size of PVC can be dynamically increased (not decreased), if StorageClass is provided with the following item `allowVolumeExpansion`.

```bash
kubectl patch pvc pv-claim --type=merge -p '{"spec":{"resources":{"requests":{"storage":"50Gi"}}}}'
```

### Tags

Tagging can be useful to identify a set of volume which can be referred clearly by an action, e.g. backups.
Adding Tags to an EBS Volume is possible in two ways:

* At volume creation, placing tags into a sepcific `StorageClass`

* By patching the PVC only after creation it by using and associating to PVC a `VolumeAttributesClass`

  * for `VolumeAttributesClass` the requirments are:
    * EKS Kubernetes >= 1.31
    * EBS CSI Driver >= v1.35.0

* [Volume Tagging](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/blob/master/docs/tagging.md)
* [Volume Modification via VolumeAttributesClass](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes/modify-volume)
* [Modify Volume example](https://github.com/kubernetes-sigs/aws-ebs-csi-driver/tree/master/examples/kubernetes/modify-volume "aws-ebs-csi-driver/examples/kubernetes/modify-volume at master · kubernetes-sigs/aws-ebs-csi-driver")

In our setup we will assign a special storage class to volume that will have a set of basic tags.
Then each PVC can be furterly tagged using a `VolumeAttributesClass` after creation.

```bash
kubectl patch pvc pv-claim --patch '{"spec": {"volumeAttributesClassName": "validator-tags"}}'
```

This is achieved in `skaffold` using a specific resource definition that instanciates the `VolumeAttributesClass` and patches the existing and targeted PVCs storage.
