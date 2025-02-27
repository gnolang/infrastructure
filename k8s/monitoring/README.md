# Monitoring

## Architecture

The monitoing infrastracture is composed of the following elements:

* `Prometheus`: collecting metrics and pushing them to Grafana
* `Otel Collector`: collecting Open Telemetry metrics and pushing them to Prometheus
* `Vector`: data pipeline tool, collecting logs from pods/containers and pushing them to Loki
* `Loki`: log aggregation system, storing and querying logs received from Vector.
* `Node Exporter`: collecting raw metrics from physical nodes and pushing them to Prometheus
* `Grafana`: UI to display monitoring data on different dashboards

## Logs

### LogQL and Vector

* filters log of a specific app/pod

```bash
{ logsource="kube" } | json  | line_format "{{ .message }}" | kubernetes_pod_namespace=`monitoring`, kubernetes_pod_labels_app=`loki`
```

* format message and filter errors

```bash
{ logsource="kube" } | json  | line_format "{{ .message }}" | logfmt message |= "error"
```

OR

```bash
{ logsource="kube" } | json  | line_format "{{ .message }}" | logfmt message |= `level=error`
```

* filter logs in GNO of a non-validator service

```bash
{ logsource="kube" } | json  | line_format "{{ .message }}" | kubernetes_pod_namespace=`gno`, kubernetes_pod_labels_gno_service!=`gnoland`
```

* filter logs in GNO of a non-RPC node

```bash
{ logsource="kube" } | json  | line_format "{{ .message }}" | kubernetes_pod_namespace=`gno`, kubernetes_pod_labels_gno_type!=`rpc`
```

### See Also

* [Kubernetes logs | Vector documentation](https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/#namespace_annotation_fields)
* [Remap with VRL | Vector documentation](https://vector.dev/docs/reference/configuration/transforms/remap/#examples-parse-key/value-logfmt-logs)
* [Log queries | Grafana Loki documentation](https://grafana.com/docs/loki/latest/query/log_queries/#label-filter-expression)
