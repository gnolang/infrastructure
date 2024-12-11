# Test6

Test6 is willing to introduce Provisioning of the Infra via IaC

Refer to:

* [General Readme](../../README.md)
* [Test5 Readme](../test5/README.md)

## Provisioning

The provisioning of the cluster was manual on AWS EKS, defining two different node group:

* general purpose, for any service that is not a validator or sentry node
* validators, for validators and sentry nodes

The idea behind this decision is that validators and sentries should be guaranteed having thier own node wothout any
other service being scheduled onto that.

For reference check [doc/k8s/node_reservation.md](../../../doc/k8s/node_reservation.md)

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
