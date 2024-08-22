# K8S Cluster

A setup for the Kubernetes cluster.

## KinD: Local dev env

### Prerequisites

* K8S (+ kubectl)
* [Kind](https://kind.sigs.k8s.io/)

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

* Generate Persistent Volumes (Gnoland and Tx-Indexer)

  ```bash
  kubectl apply -f core/gno-land/storage/ -f core/indexer/storage/
  ```

* Spin up ALL services

  ```bash
  kubectl apply -f core/ -R
  ```

---

### Traefik

TODO:

---

## Monitoring services

* Add Namespace

```bash
  kubectl apply -f cluster/namespaces/monitoring.yaml
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

* Spin up Grafan service

  ```bash
  kubectl apply -f monitoring/grafana/deploys/
  ```

* Check out the Grafana dashboard by visiting [http://127.0.0.1:3000/dashboards](http://127.0.0.1:3000/dashboards) and after logging in navigate to the `Gnoland Dashboard` (use the password defined into `grafana.ini` file for the `admin` user)

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
