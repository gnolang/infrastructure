# Test6

Test6 is willing to introduce Provisioning of the Infra via IaC

Refer to:

* [General Readme](../../README.md)
* [Test5 Readme](../test5/README.md)

## Provisioning

The provisioning of the cluster was for the first time by IaC.

* The general architecture is the one illustrated in [Test5 Provisioning](../test5/README.md#provisioning).
* EKS cluster is provisioned using [Tearraform](../../provisioning/README.md).
* Terraform commands are listed in [Provisioning section](../../provisioning/README.md#running).
* Define useful and coherent env vars

```bash
export TF_VAR_gno_project="test6"
export TF_VAR_eks_cluster_admin_user="eks-username"
```

## Internal Helm chart version

* The following Helm chart version is used for internal helm templates: `0.1.0`

## Env Files

The following env files should be created:

* Gnoweb secrets `overlays/eks/gnoweb/secrets/.env` (see [test6.eks.gnoweb.sample.env](./overlays/eks/gnoweb/secrets/test6.eks.gnoweb.sample.env))
* Gnofaucet secrets `overlays/eks/gnofaucet/secrets/.env` (see [test6.eks.gnofaucet.sample.env](./overlays/eks/gnofaucet/secrets/test6.eks.gnofaucet.sample.env))

## Betterstack setup for Monitors and Status Page

* Run the script

```bash
cd ../../../tools/betterstack/
go run main.go -token ${BETTER_AUTH_TOKEN} -group test6 -fqdn test6.gno.land -prefix Test 6 -extra-path ../../k8s/core/test6/betterstack/extra-services.json
```
