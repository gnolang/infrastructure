# Provisioning

## Why Terraform ?

Terraform is one of the reference tecnologies for provisioning using a IaC (Infrastructure as Code) approach.
It is declative and employs the HCL language (Hashicorp configuration language).

## What about Ansible ?

It is possible to leverage the best of both worlds, adopting a hybrid approach:
> Terraform for infrastructure provisioning, Ansible for post-provisioning tasks.

Terraform output variables can be used as input in Ansible.

## Tf in a Nutshell

### Commands

Terrfaorm provisioning passes through 3 phases:

- init; setups the provisioning environment, downloading required provdiers (such as AWS)
- plan; prepares and verifies all the provisioning steps checking all required input values status
- apply; effecively performs the provisioning steps prepared in the previous phase

Other useful commands:

- validate; validates the syntax of the tf files
- fmt; formats text of structures in tf files
- output; show output once provisioning has been applied

### Concepts

- The file `terraform.tfstate` rewcords the  current state of the infra, which is the base to reconcile
- Terraform automatically recognizes files containing variables values with the follwoing filename convention,terraform.tfvars(.json) / *auto.tfvars(.json)
- Terraform `modules` can be defined as reusable libraries

## Terraform Tips

### importing a resource in a for-each loop

```bash
terraform import 'aws_eks_addon.addons["coredns"]' testX-cluster:coredns
```

### show raw output of a specific output variable

```bash
terraform output -raw kube-config
```
