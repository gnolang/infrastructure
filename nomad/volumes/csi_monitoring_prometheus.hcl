id          = "csi-monitoring-prometheus"
name        = "csi-monitoring-prometheus"
external_id = "csi-monitoring-prometheus"

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
    uid  = "65534"
    gid  = "65534"
    mode = "770"
}
