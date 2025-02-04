# Storage Backup

Storage backup referes to the opperation of backing up storage containing sensible data,
such as validator nodes' storage.

## AWS EBS

In AWS EKS, storage for validator nodes is achieved through the EBS CSI storage class, allowing
dynamic provisioning on volumes as soon as PVC resources are deployed on the cluster.

In the special case of validator nodes, these PVCs will hold all the sensible data, and should be the backup target.
To backup this storage created dynamically two steps are required:

* Tagging all the EBS volumes that should have a regular backup [via PVC tagging](../../../k8s/aws-eks/README.md#tags)
* Defining an AWS Backup Plan both via AWS Management Console or via Provisioning (e.g. Terraform),
that targets in its rule the given tagged EBS volumes

## Snapshots

Regular snapshots of a validator should be taken by:

* using a snapshot command/routine, like explained in [Gnops](https://gnops.io/articles/effective-gnops/snapshot-nodes/)
* deploying a Kubernetes CronJob for the specific cluster.
