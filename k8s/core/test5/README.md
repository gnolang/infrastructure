# Test5

Test5 is aligned on a dedicated setup using existing resources and tools.

Refer to [General Readme](../../README.md).

## Helm

* Helm templates for validator and sentry nodes are defined
* Different value are provided per folder

## Skaffold

* Skaffold dedicated file [k8s/core/test5/skaffold.yaml](skaffold.yaml)

* Gno Core replacement: [k8s/cluster/skaffold/gnocore-test5-skaffold.yaml](../../cluster/skaffold/gnocore-test5-skaffold.yaml)

* New profiles
  * dev-test5 (activated also by env var `GNO_ENV=test5`)
  * eks-test5 (activated also by env var `GNO_ENV=prod-test5`)
  * applied into existing `monitoring` skaffold file [k8s/cluster/skaffold/monitoring.yaml](../../cluster/skaffold/monitoring.yaml)

* Helm releases, using `values` per profile to bootstrap

## Running

* Attach to the proper cluster
* Define an appropriate env var
* Run skaffold from this folder [k8s/core/test5/skaffold.yaml](skaffold.yaml)
