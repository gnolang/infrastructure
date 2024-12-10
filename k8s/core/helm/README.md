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
helm template gno-validator . --output-dir ./out --values val-00values.yaml
```

## Handling template resources

### Install

Renders the templates in the chart and deploys it into a Kubernetes cluster

```bash
helm intall gno-validator . --values val-00/values.yaml
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
