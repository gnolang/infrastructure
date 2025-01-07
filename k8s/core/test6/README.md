# Test6

Test6 is willing to introduce Provisioning of the Infra via IaC

Refer to:

* [General Readme](../../README.md)
* [Test5 Readme](../test5/README.md)

## Provisioning

The provisioning of the cluster was for the first time by IaC.

* VPC was still manually created
* EKS cluster was provisioned using [Tearraform](../../provisioning/README.md).

The general architecture is the one illustrated in [Test5 Provisioning](../test5/README.md#provisioning)

Terraform commands are:

```bash
terraform init
terraform plan -var 'gno_project=test6'
terraform apply -auto-approve
```

### Env Files

The following env files should be created:

* Gnoweb secrets `overlays/eks/gnoweb/secrets/.env` (see [test6.eks.gnoweb.sample.env](./overlays/eks/gnoweb/secrets/test6.eks.gnoweb.sample.env))
* Gnofaucet secrets `overlays/eks/gnofaucet/secrets/.env` (see [test6.eks.gnofaucet.sample.env](./overlays/eks/gnofaucet/secrets/test6.eks.gnofaucet.sample.env))

## Betterstack setup for Monitors and Status Page

Run the script

```bash
cd ../../../tools/betterstack/
go run main.go -token ${BETTER_AUTH_TOKEN} -group test6 -fqdn test6.gno.land -prefix Test 6 -extra-path ../../k8s/core/test6/betterstack/extra-services.json
```
