# Helm templates

## Running an helm template

### Dry Run

To render all the templates and produce a single YAML file as output (if templates does not contain requested values)

```bash
helm template gno-validator . --output-dir ./out --dry-run
```

### Generate Output

Run the template against a set of values

```bash
helm template gno-validator . --output-dir ./out --values val-00/values.yaml
```

## Handling template resources

### Install

Renders the templates in the chart and deploys it into a Kubernetes cluster

```bash
helm install gno-validator . --values val-00/values.yaml
```

### Upgrading / Overriding

```bash
helm upgrade gno-validator . --values val-00/values.yaml
```

### Delete

Fully remove Helm release and all related resources

```bash
helm delete gno-validator
```

## Reference Values for chart

| Key | Description | Type (Default) |
|----|----|----|
| `app` | App section | |
| `app.name` | Label for app name | string |
| `app.role` | Label for app role | string |
| `app.type` | whether app is an RPC node or a validator | string |
| `app.namespace` | app namespace | string (gno) |
| `app.compiled` | whether using binary or compile from source code | |
| `app.compiled.branch` | git source code branch to compile from | string (master) |
| `app.initEnv` | env for initializing  deployment | string |
| `storage` | Storage section | |
| `storage.capacity` | Required capacity for storage | string |
| `storage.local` | Whether storage is local | |
| `storage.local.path` | Path in host (when using local storage) | string |
| `storage.class` | Storage class to be used | string |
| `storage.volumeAttributsClass` | Volume attributes classname used to add attributes to EBS volumes | string |
| `svc` | Svc section | |
| `svc.name` | Name given to service | string |
| `svc.type` | Kind of k8s service (LoadBalancer, ClusterIP) | string (ClusterIP) |
| `placement` | Placement section (Pod tolerations and resources) | |
| `placement.tolerations.enabled` | If tolerations are enabled | boolean (false) |
| `placement.resources.limits.cpu` | Corresponds to spec.template.containers[].resources.limits.cpu | string |
| `placement.resources.limits.memory` | Corresponds to spec.template.containers[].resources.limits.memory | string |
| `placement.resources.requests.cpu` | Corresponds to spec.template.containers[].resources.requests.cpu | string |
| `placement.resources.requests.memory` | Corresponds to spec.template.containers[].resources.requests.memory | string |
| `ingress` | Ingress section | |
| `ingress.enabled` | If ingress is enabled | boolean (false) |
| `ingress.rules.host` | Rule for entrypoint (Traefik) | string |
| `ingress.port` | Service port to be referenced by ingress | string |
| `ingress.tls` | Deploy TLS version of entrypoint | boolean (false) |
| `ingress.certresolver` | Name of certresolver to be used (only if ingress.tls is true) | string |
| `gnoland` | Gnoland config section | |
| `gnoland.config` | Override configuratiion section. Any inner key will replace original gnoland config. e.g. `gnoland.config.p2p`seeds`| string |
| `global` | Global values section | |
| `global.genesisUrl` | Url of reference genesis file | string |
| `global.binaryVersion` | Gnoland binary version to be used in all the deployments | string |
