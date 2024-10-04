# TODO

## Core

* Traefik support
  * traefik TLS
  * traefik Gateway API

* Gno
  * Config of validator vs RPC node
  * Node bootstrap
    * Setup of `genesis` file into persistent volumes
      * [How to mount data file in kubernetes via pvc? - Stack Overflow](https://stackoverflow.com/questions/51648465/how-to-mount-data-file-in-kubernetes-via-pvc "How to mount data file in kubernetes via pvc? - Stack Overflow")
      * [[k8s] How to mount local directory (persistent volume) to Kubernetes pods of Docker Desktop for Mac? | by Julien Chen | Medium](https://julien-chen.medium.com/k8s-how-to-mount-local-directory-persistent-volume-to-kubernetes-pods-of-docker-desktop-for-mac-b72f3ca6b0dd "[k8s] How to mount local directory (persistent volume) to Kubernetes pods of Docker Desktop for Mac? | by Julien Chen | Medium")
      * [Volumes | Kubernetes](https://kubernetes.io/docs/concepts/storage/volumes/#using-subpath "Volumes | Kubernetes")

    * `SOLUTION` Two possibilities, with mount files and init containers

* Gnoweb
  * Providing env var into command argument
    * [Supporting multiple secrets stored in one yaml file for secretGenerator · Issue #1135 · kubernetes-sigs/kustomize](https://github.com/kubernetes-sigs/kustomize/issues/1135#issuecomment-497132880)

## Monitoring

* Alert Manager

## Secret Management

* SOPS + Age (Integrated ksops with ArgoCD)
* External Secrets Operator to fetch secrets + AWS Secrets Manager
* HashiCorp Vault (Not easy to configure)
