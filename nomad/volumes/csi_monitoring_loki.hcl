id          = "csi-monitoring-loki"
name        = "csi-monitoring-loki"
external_id = "csi-monitoring-loki"

type      = "csi"
namespace = "monitoring"

plugin_id = "digitalocean"

capacity_min = "100G"
capacity_max = "200G"

capability {
    access_mode     = "single-node-writer"
    attachment_mode = "block-device"
}

parameters {
    uid  = "10001"
    gid  = "10001"
    mode = "770"
}
