# K8S Cluster

Setup for the Kubernetes cluster.

## KinD: Local dev env

### Prerequisites

* K8S (+ kubectl)
* [Kind](https://kind.sigs.k8s.io)
* [Skaffold](https://skaffold.dev)
* [Helm](https://helm.sh)

### Using KinD

In order to test a minimal setup of a K8s cluster in a local environment, it may be useful to use [Kind](https://kind.sigs.k8s.io/)

* Build the Cluster with Kind

  ```bash
  kind create cluster --name gnolive --config=cluster/kind/kind.yaml
  ```

* Get cluster info

  ```bash
  kubectl cluster-info --context kind-gnolive
  ```

* (opt.) Delete cluster using

  ```bash
  kind delete cluster --name gnolive
  ```

### Gotchas

* It maky take a little bit to the cluster to deploy all the required resources. Be patient...

* Cluster created using `Kind` is configured to expose port 3000 on the control plane host using `extraPortMappings`.
This method should work _out of the box_ on any host, but it may be influenced by a combination of the versions of Docker and Kubernetes.

* (alternatively) Expose dashboard service manually

  ```bash
  kubectl port-forward service/grafana 3000:3000
  ```

## Env Files

The following env files should be created:

* Traefik secrets `traefik/ingress-route/secrets/sample.env` (_ONLYFOR LETSENCRYPT WITH DNSCHALLENGE_, see [sample.env](./traefik/ingress-route/secrets/sample.env))
* Grafana secrets `monitoring/grafana/secrets/grafana.ini` (see [grafana.ini.sample](./monitoring/grafana/secrets/grafana.ini.sample))

---

## Core services

* Add Namespace

```bash
  kubectl apply -f cluster/namespaces/core.yaml
```

`Tip`: to switch default namespace check [here](#k8s-tips)

### Gnoland

* Generate Persistent Volume

  ```bash
  kubectl apply -f core/gno-land/storage/
  ```

* Spin up Gno service

  ```bash
  kubectl apply -f core/gno-land/deploys/
  ```

* (opt.) Run Stress Tests - SUPERNOVA

  ```bash
  kubectl apply -f core/jobs/supernova.yaml
  ```

### All core services in a shot

* Using [skaffold](https://skaffold.dev/). FULL STOP!

  ```bash
  skaffold run
  ```

### OR

* Generate Persistent Volumes (Gnoland and Tx-Indexer)

  ```bash
  kubectl apply -f core/gno-land/storage/ -f core/indexer/storage/
  ```

* Spin up ALL services

  ```bash
  kubectl apply -f core/ -R
  ```

---

## Traefik

* Generate CRD and RBAC

  ```bash
  kubectl apply -f traefik/ingress-route/crd.yaml -f traefik/ingress-route/rbac.yaml
  ```

* Spin up service ([IngressRoute](https://doc.traefik.io/traefik/routing/providers/kubernetes-crd/) version)

  ```bash
  kubectl apply -f traefik/ingress-route/traefik.yaml
  ```

---

## Monitoring services

* Add Namespace

```bash
  kubectl apply -f cluster/namespaces/monitoring.yaml
```

### All monitoring services in a shot

* Using [skaffold](https://skaffold.dev/). FULL STOP!

  ```bash
  skaffold run
  ```

### Grafana

* create the file `secrets/grafana.ini` containing only a plain text password for the Grafana dashboard
(just a plain string no key/value, no quotes)

* Generate secrets

  ```bash
  kubectl apply -k monitoring/grafana/secrets/
  ```

* Generate Config Map for static config files

  ```bash
  kubectl apply -k monitoring/grafana/configmaps/
  ```

* Generate Volumes

  ```bash
  kubectl apply -f monitoring/grafana/storage/
  ```

* Spin up Grafana service

  ```bash
  kubectl apply -f monitoring/grafana/deploys/
  ```

* Check out the Grafana dashboard by visiting [http://127.0.0.1:3000/dashboards](http://127.0.0.1:3000/dashboards) and after logging in navigate to the `Gnoland Dashboard` (use the password defined into `grafana.ini` file for the `admin` user)

---

## Cleaning up Cluster

* Using [skaffold](https://skaffold.dev/).

  ```bash
  skaffold delete
  ```

### Issues with PVC in AWS EKS

Generally speaking in AWS EKS storage is represented via EBS volumes which are related to PVC resources in Kubernetes.
When creating the cluster from scratch, the given configuration will also create:

* the CSI (Container Storage Interface) resource for AWS EKS
* the AWS Storage Class for EBS volumes

When resources are deleted via `skaffold`, it may blindly remove this specific AWS resources without waiting the removal of other resources.
In this scenario PVC and in turn corresponding PODs will remain in a pending removal status, since there is not anymore a storage class
(which was already removed) able to satisfy the removal request.
When this happens the best thing to do in order to clean up is to manually re-add and re-remove the storage elements.

```bash
k apply -k aws-eks/storage
# ... wait pvc/pod full removal
# k get pvc -A -w
k delete -k aws-eks/storage
```

---

## K8s Tips

* Change current Namespace

```bash
kubectl config set-context --current --namespace=gno
```

* Apply all the YAML files in a folder tree

```bash
kubectl apply -R -f dir
```

* Get logs from init containers

```bash
kubectl logs --previous <pod_name> -c <init_container_name>
```

* Disruptive and forced deletion of a Pod

```bash
kubectl delete pod <pod_name> -n <namespace> --grace-period=0 --force
```

* Local DNS name resolution for Traefik -> Edit `/etc/hosts` on localhost machine by appending:

```bash
127.0.0.1 gnoland.tech
127.0.0.1 rpc.gnoland.tech
127.0.0.1 web.gnoland.tech
127.0.0.1 indexer.gnoland.tech
127.0.0.1 faucet.gnoland.tech
127.0.0.1 grafana.gnoland.tech
```

* Get specific information on resource capacity of a node

```bash
kubectl describe nodes <node-name>
```

and check output

```yaml
Capacity:
  cpu:                2
  memory:             3922840Ki
  pods:               29
  ...
```

* Generate a single K8s Job resource from an existing CronJob resource

```bash
kubectl create job --from=cronjob/<cron-job-resource> <custom-job-resource-name>
```

---

## Testnets setup in public environment

* Preliminary steps
  * Generate secrets and config (see [static-config-generator](../tools/static-secrets-generator/))
  * Generate Genesis file
  * Generate and store safe Captcha secrets (for Faucet)
  * Spin up the provisioning of a public cluster

* Setup
  * Adjust validators' config
  * Define generic parameters for Helm
    * URL for Genesis file
    * version of reference Gno binary
  * Generate environment files for requiring services
  * Adjust subdomains
    * Define overriding subdomains
    * Setup subdomains in them public DNS registry
    * Adjust pointing CNAME targets after deploy of resources
  * Spin up deploy of infra pointing the right cluster (using `skaffold` and `kubectl`)
  * Define public _mointors_ and _status page_ for testnet and setup them in Betterstack (see [Betterstack tool](../tools/betterstack/README.md))

* Teardown
  * Remove deployed resources from cluster
  * Cleanup public domain
  * Cleanup status _mointors_ and _status page_ in Betterstack
  * Fully delete cluster infrastructure

---

## Resources

### Security Context

* [Kubernetes SecurityContext with practical examples | by Eugene Butan | Marionete | Medium](https://medium.com/marionete/kubernetes-securitycontext-with-practical-examples-67d890558d11)
* [Configure a Security Context for a Pod or Container | Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/security-context/)

### Service Account

* [9.5 Using projected volumes to combine volumes into one](https://wangwei1237.github.io/Kubernetes-in-Action-Second-Edition/docs/Using_projected_volumes_to_combine_volumes_into_one.html)
* [Configure Service Accounts for Pods | Kubernetes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/?source=post_page-----434ff2cd1483--------------------------------#service-account-token-volume-projection)
* [Managing Service Accounts | Kubernetes](https://kubernetes.io/docs/reference/access-authn-authz/service-accounts-admin/?source=post_page-----434ff2cd1483--------------------------------#bound-service-account-token-volume)

### Downward API

* [9.4 Passing pod metadata to the application via the Downward API](https://wangwei1237.github.io/Kubernetes-in-Action-Second-Edition/docs/Passing_pod_metadata_to_the_application_via_the_Downward_API.html)

### AWS EKS

* [EKS Pod Identity or IAM Roles for Service Accounts (IRSA)](https://awsmorocco.com/eks-pod-identity-or-iam-roles-for-service-accounts-irsa-e32ea9331f27)

### Kustomize

* [Kubernetes Kustomize Tutorial (Comprehensive Guide)](https://devopscube.com/kustomize-tutorial/)
* [Kubernetes: using a delete patch with kustomize | Fabian Lee : Software Engineer](https://fabianlee.org/2023/04/20/)

### Skaffold

* [Simplify your DevOps using Skaffold | Google Cloud Blog](https://cloud.google.com/blog/topics/developers-practitioners/simplify-your-devops-using-skaffold/)
* [Profiles | Skaffold](https://skaffold.dev/docs/environment/profiles/)
* [skaffold.yaml | Skaffold](https://skaffold.dev/docs/references/yaml/?version=v4beta11)
* [skaffold/examples at main · GoogleContainerTools/skaffold](https://github.com/GoogleContainerTools/skaffold/tree/main/examples)

### Log Rotation

* [Logging Architecture | Kubernetes](https://kubernetes.io/docs/concepts/cluster-administration/logging/#log-rotation)
* [Logging for Amazon EKS - AWS Prescriptive Guidance](https://docs.aws.amazon.com/prescriptive-guidance/latest/implementing-logging-monitoring-cloudwatch/kubernetes-eks-logging.html)
