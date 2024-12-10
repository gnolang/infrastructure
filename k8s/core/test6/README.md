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

### AWS EKS

* Region: `eu-central-1`
* Cluster name: `test6-eks-cluster`
* Node groups:
  * `test6-ng-generic`
  * `test6-ng-validators`
    * Node Labels: `reserved = validator-node`
    * Node Taints: `type = validator -> NoSchedule`
* Security Groups Inbound Ports:
  * 80 - HTTP / Traefik
  * 443 - HTTPS / Traefik
  * 26656 - TCP Validators P2P

## Helm

* Helm templates for validator and sentry nodes are defined
* Different value are provided in the folder `validators/`, one per each sentry/validator

## Skaffold

* Skaffold dedicated file [k8s/core/test6/skaffold.yaml](skaffold.yaml)

* Gno Core replacement: [k8s/core/test6/cluster/skaffold/gnocore-test6-skaffold.yaml](./cluster/skaffold/gnocore-test6-skaffold.yaml)

* New profiles
  * dev-test6 (activated also by env var `GNO_INFRA=test6`)
  * eks-test6 (activated also by env var `GNO_INFRA=prod-test6`)
  * applied into existing `monitoring` skaffold file [k8s/cluster/skaffold/monitoring-skaffold.yaml](../../cluster/skaffold/monitoring-skaffold.yaml )

* Helm releases, using `values` per profile to bootstrap using skaffold definition [k8s/core/test6/cluster/skaffold/gnocore-test6-helm-skaffold.yaml](./cluster/skaffold/gnocore-test6-helm-skaffold.yaml)

## Setup

### Env Files

The following env files should be created:

* Gnoweb secrets `overlays/eks/gnoweb/secrets/.env` (see [test6.eks.gnoweb.sample.env](./overlays/eks/gnoweb/secrets/test6.eks.gnoweb.sample.env))
* Gnofaucet secrets `overlays/eks/gnofaucet/secrets/.env` (see [test6.eks.gnofaucet.sample.env](./overlays/eks/gnofaucet/secrets/test6.eks.gnofaucet.sample.env))

## Running

* Attach to the proper cluster (dev or prod)
* Define an appropriate value for `GNO_INFRA` env var
* Run skaffold from this folder [k8s/core/test6/skaffold.yaml](skaffold.yaml)

## Betterstack setup for Monitors and Status Page

Run the script

```bash
cd ../../../tools/betterstack/
go run main.go -token ${BETTER_AUTH_TOKEN} -group test6 -fqdn test6.gno.land -prefix Test 6 -extra-path ../../k8s/core/test6/betterstack/extra-services.json
```
