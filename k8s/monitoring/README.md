# Monitoring

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

### See Also

* [Kubernetes logs | Vector documentation](https://vector.dev/docs/reference/configuration/sources/kubernetes_logs/#namespace_annotation_fields)
* [Remap with VRL | Vector documentation](https://vector.dev/docs/reference/configuration/transforms/remap/#examples-parse-key/value-logfmt-logs)
* [Log queries | Grafana Loki documentation](https://grafana.com/docs/loki/latest/query/log_queries/#label-filter-expression)
