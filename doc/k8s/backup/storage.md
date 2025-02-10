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

### Requirements for K8s CronJob

The CronJob that handles the snapshot taks has several requirments:

* a mounted Volume that refers to the PVC from a target validator/sentry Pod in read-only mode
  * scheduling on the same node of sentry node
  * using `Affinity` rules to allow the CronJob Pod to be scheduled into the same node where the validator/sentry

* an RBAC which allows to handle scaling of a deployment into the cluster from within the job, for snapshot consistency
  * installing and using kubectl control plane commands from within the job in a sandboxxed environment

* the permissions to access an S3 bucket prof withing the POD
  * installing AWS CLI
  * uploading directly by piping tar compress commmand to S3 upload command
  * accessing to bucket can granted by [EKS POD Identitity](https://docs.aws.amazon.com/eks/latest/userguide/pod-identities.html), which enables PODs to automattically inherit the IAM role of the node their are scheduled in

### Requirements for AWS Node running job

* A Policy in the node IAM Role to get Full Access to AWS S3 target Bucket (e.g. `CustomSnapshotsBucketFullAccess`)

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "arn:aws:s3:::gno-snapshot"
        },
        {
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "s3:PutObject",
                "s3:DeleteObject",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload"
            ],
            "Resource": "arn:aws:s3:::gno-snapshot/*"
        }
    ]
}
```
