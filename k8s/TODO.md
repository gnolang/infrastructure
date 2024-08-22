# TODO

## Cluster

* Volumes setup in Amazon EKS

## Core

* Traefik support
  * traefik configuration
  * traefik labels in deploment

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
    * [cloud sql proxy - How to use environment variable in kubernetes container command? - Stack Overflow](https://stackoverflow.com/questions/56687542/how-to-use-environment-variable-in-kubernetes-container-command "cloud sql proxy - How to use environment variable in kubernetes container command? - Stack Overflow")

## Monitoring

* ALL
