# Helm templates

## Running an helm template

### Dry Run

To render all the templates and produce a single YAML file as output

```bash
helm template gno-validator . --output-dir ./out --dry-run
```

### Generate Output

Run the template with against a set of values

```bash
helm template gno-validator . --output-dir ./out --values values.yaml
```

## Handling template resources

### Intall

Renders the templates in the chart and deploys it to a Kubernetes cluster

```bash
helm intall gno-validator . --values val-01/values.yaml
```

### Upgrading / Overriding

```bash
helm upgrade gno-validator . --values val-01/values.yaml
```

### Delete

Fully remove Helm release and all related resources

```bash
helm delete gno-validator
```
