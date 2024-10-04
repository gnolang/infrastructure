id          = "csi-monitoring-grafana"
name        = "csi-monitoring-grafana"
external_id = "csi-monitoring-grafana"

type      = "csi"
namespace = "monitoring"

plugin_id = "digitalocean"

capacity_min = "10G"
capacity_max = "100G"

capability {
    access_mode     = "single-node-writer"
    attachment_mode = "block-device"
}
