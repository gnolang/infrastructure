job "node-exporter" {
  type        = "system"
  datacenters = ["*"]
  namespace   = "monitoring"

  group "monitoring-exporter" {
    count = 1

    network {
      port "http" {
        to           = 9100
        host_network = "private"
      }
    }

    task "prometheus" {
      driver = "docker"

      # this is required to access the docker socket
      user = "root"

      config {
        image = "prom/prometheus:v2.52.0"

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "/var/run/docker.sock:/var/run/docker.sock",
        ]

        extra_hosts = ["host.docker.internal:host-gateway"]
      }

      template {
        destination = "local/prometheus.yml"
        data        = <<EOF
---
global:
  scrape_interval: "15s"

remote_write:
  - url: https://prometheus.infra.allinbits.vip/api/v1/write

scrape_configs:
  - job_name: 'nomad_agent'
    metrics_path: /v1/metrics
    params:
      format: ['prometheus']
    static_configs:
      - targets: ['{{ env "NOMAD_IP_http" }}:4646']
        labels:
          nomad_id: "{{ env "node.unique.id" }}"
          datacenter: "{{ env "node.datacenter" }}"
          region: "{{ env "node.region" }}"

# TODO(albttx): expose prometheus on all docker engines
#  - job_name: "docker"
#    static_configs:
#      - targets: ["localhost:9323"]


  # - job_name: "docker-containers"
  #   docker_sd_configs:
  #     - host: unix:///var/run/docker.sock

  #   relabel_configs:
  #     # Only keep containers that have a `prometheus-job` label.
  #     - source_labels: [__meta_docker_container_label_prometheus_job]
  #       regex: .+
  #       action: keep
  #     # Use the task labels that are prefixed by `prometheus-`.
  #     - regex: __meta_docker_container_label_prometheus_(.+)
  #       action: labelmap
  #       replacement: $1
EOF
      }

      resources {
        cpu    = 100
        memory = 300
      }
    }

  }

  group "monitoring-collector" {
    count = 1

    restart {
      attempts = 3
      delay    = "20s"
      mode     = "delay"
    }

    network {
      port "http" {
        static       = 9100
        host_network = "private"
      }
    }


    task "node-exporter" {
      driver = "docker"

      config {
        image      = "prom/node-exporter:v1.5.0"
        force_pull = true
        ports      = ["http"]

        volumes = [
          "/proc:/host/proc",
          "/sys:/host/sys",
          "/:/rootfs"
        ]

        logging {
          type = "journald"
          config {
            tag = "NODE-EXPORTER"
          }
        }
      }

      service {
        name     = "node-exporter"
        provider = "nomad"
        port     = "http"
        tags = [
          "metrics",
          "hostname=${attr.unique.hostname}",
        ]
        check {
          type     = "http"
          path     = "/metrics/"
          interval = "10s"
          timeout  = "2s"
        }
      }

      resources {
        cpu    = 400
        memory = 3000
      }
    }
  }
}
