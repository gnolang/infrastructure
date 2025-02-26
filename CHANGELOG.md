# Changelog

All notable changes to this project will be documented in this file.
Major changes are referred to testnests

## Test 6

* Security improvements
* Automating creation of testnets from provisioning steps to cluster setup and running
* Improved Helm template, now also able to create node from a custom branch of the Gno repository
* Fully dynamic Gnoland binary configuration via Helm values
* Supporting a fully P2P oriented configuration for Sentry nodes and Validators
* Allowing replacement of the Gnoland binary with an in-place compiled version, even starting from a branch
* Fixing several issues preventing the Observability Stack to work as expected
* Introducing AWS resources provisioning with Terraform, creating VPC, EKS cluster, EC2 nodes, Security Groups ...
* Storing Terraform state remotely instead of locally, leveraging AWS S3 for state folder and DynamoDB for state locking
* Binding Helm Chart version to Testnets, for Test6 it is `0.2.0`
* Introducing backups and snapshots
* Creating Kubernetes CronJobs to spin up snapshots in AWS S3
* Dynamic tagging of PVCs in AWS EBS using AWS Tags
* Provisioning AWS Backup Plan in Terraform targeting EBS Volumes dynamically

## Test 5

* Initial setup collecting existing Nomad configuration and Dockerfile templates
* Added an initial setup in Kubernetes leveraging: `Skaffold` and `Kustomize`
* Created a basic `Helm` template to spin up validators and sentry nodes
* Created a custom tool to generate key pairs for validatrs, sentries and RPCs
* Created a custom tool to create monitors and update status page in the BetterStack service
* Minor security updates
