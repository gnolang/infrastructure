job "tenderduty" {
  type = "service"

  datacenters = ["*"]
  region      = "eu-london"
  namespace   = "monitoring"

  group "tenderduty" {
    count = 1

    ephemeral_disk {
      size    = 500
      sticky  = true
      migrate = true
    }

    network {
      port "http" {
        to           = 8888
        host_network = "private"
      }

      port "metrics" {
        to           = 28686
        host_network = "private"
      }
    }

    service {
      name     = "tenderduty-http"
      port     = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.tenderduty.rule=Host(`tenderduty.infra.allinbits.vip`)",
        "traefik.http.routers.tenderduty.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.tenderduty.tls=true",
        "traefik.http.routers.tenderduty.tls.certresolver=letsencrypt",
      ]
    }

    service {
      name     = "tenderduty-metrics"
      port     = "metrics"
      provider = "nomad"

      tags = [
        "metrics",
        "traefik.enable=true",
        "traefik.http.routers.tenderduty-metrics.rule=Host(`tenderduty.infra.allinbits.vip`) && PathPrefix(`/metrics`)",
        "traefik.http.routers.tenderduty-metrics.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.tenderduty-metrics.tls=true",
        "traefik.http.routers.tenderduty-metrics.tls.certresolver=letsencrypt",
      ]
    }

    task "tenderduty" {
      driver = "docker"

      resources {
        cpu    = 3000
        memory = 8000
      }

      config {
        image        = "ghcr.io/blockpane/tenderduty"
        force_pull   = true
        network_mode = "bridge"
        args         = ["-state=/alloc/data/tenderduty-state.json"]
        ports        = ["http", "metrics"]
        volumes = [
          "local/tenderduty:/var/lib/tenderduty"
        ]
      }

      template {
        destination = "local/tenderduty/config.yml"
        data        = <<EOF
---
enable_dashboard: yes
listen_port: 8888
hide_logs: no
node_down_alert_minutes: 3
node_down_alert_severity: critical

prometheus_enabled: yes
prometheus_listen_port: 28686

pagerduty:
  enabled: no

discord:
  enabled: no

telegram:
  enabled: no
  api_key: "5555555555:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA"
  channel: "-666666666"

slack:
  enabled: yes
{{- with nomadVar "nomad/jobs/tenderduty" }}
  webhook: "{{ .slack_webhook }}"
{{- end }}
EOF
      }

      dynamic "template" {
        for_each = fileset("./tenderduty/", "*.yml")

        content {
          destination = "local/tenderduty/chains.d/${template.value}"
          data        = file("./tenderduty/${template.value}")
        }
      }
    }
  }
}
