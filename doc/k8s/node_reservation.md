# Reserving a Node for a Single Pod in Kubernetes

In Kubernetes, it's possible to reserve an entire node for a single pod.
This is useful for validators node, where we want that each pod related to a validator is scheduled into a node and nothing else,

> 1 Kubernetes Node ~ 1 Validator Node

## 1. Taints and Tolerations

Taints on the the node force that only pods with a matching toleration can be scheduled on it.
This prevents any other pods without the matching toleration from being scheduled on the node.

* Taint the Node

```bash
kubectl taint nodes <node-name> type=validator:NoSchedule
```

* Add Toleration to the Pod

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: val-pod
spec:
  tolerations:
  - key: "type"
    operator: "Equal"
    value: "validator"
    effect: "NoSchedule"
  containers:
  - name: gno-validator
    image: gno-val:latest
```

## 2. Pod Anti-Affinity

Use **pod anti-affinity** to prevent other pods from being scheduled on the same node.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: val-pod
spec:
  affinity:
    podAntiAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchExpressions:
          - key: gno.type
            operator: In
            values:
            - "validator"
        topologyKey: "kubernetes.io/hostname"
  containers:
  - name: gno-validator
    image: gno-val:latest
```

This configuration specifies that no other pod with an `gno.type=validator` label can be scheduled on the same node as this pod.

## 3. Dedicated Nodes Using Node Selector Labels

By labeling nodes as dedicated to specific workloads, only certain pods are scheduled on them.

* Label the Node

```bash
kubectl label nodes <node-name> reserved=validator-node
```

* Use Node Selector in the Pod Spec

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: val-pod
spec:
  nodeSelector:
    reserved: validator-node
  containers:
  - name: gno-validator
    image: gno-val:latest
```

## 4. Resource Requests and Limits

By setting high **resource requests and limits**, the pod can consume all resources on the node, effectively blocking others from being scheduled there.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: val-pod
spec:
  containers:
  - name: gno-validator
    image: gno-val:latest
    resources:
      requests:
        memory: "16Gi"
        cpu: "4"
      limits:
        memory: "16Gi"
        cpu: "4"
```

Let's assume the node has 4 CPUs and 32Gi of memory. Setting the pod’s resource requests to these values will reserve all resources on the node.

## Resources

* [Kubernetes Taints & Tolerations: Tutorial With Examples - Kubecost Blog](https://blog.kubecost.com/blog/kubernetes-taints/)
* [Taints and Tolerations | Kubernetes](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/)
