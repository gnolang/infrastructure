# Provisioning

## Why Terraform ?

Terraform is one of the reference tecnologies for provisioning using a IaC (Infrastructure as Code) approach.
It is declative and employs the HCL language (Hashicorp configuration language).

## What about Ansible

It is possible to leverage the best of both worlds, adopting a hybrid approach:
> Terraform for infrastructure provisioning, Ansible for post-provisioning tasks.

Terraform output variables can be used as input in Ansible.

different phases
- init
- plan
- apply

- validate
- fmt
- output

terraform.tfstate -> current state of the infra
infra current state is recorded in a "state" -> base to reconcile (disabling retrieving state and relying on local state as cahce)

terraform.tfvars(.json) / *auto.tfvars(.json) -> file containing variables values

terraform modules -> reusable libraries

## Terraform Tips

### importing a resource in a for-each loop

```bash
terraform import 'aws_eks_addon.addons["coredns"]' testX-cluster:coredns
```
