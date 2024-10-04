job "alertmanager" {
  type = "service"

  datacenters = ["do_*"]
  region      = "eu-london"
  namespace   = "monitoring"

  group "monitoring" {
    count = 1

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    ephemeral_disk {
      size    = 2000
      sticky  = true
      migrate = true
    }

    network {
      port "http" {
        static       = 9093
        host_network = "private"
      }
    }

    service {
      name     = "alertmanager"
      provider = "nomad"
      port     = "http"
      tags = [
        "metrics",
        "traefik.enable=true",
        "traefik.http.routers.alertmanager-ui.rule=Host(`alertmanager.infra.allinbits.vip`)",
        "traefik.http.routers.alertmanager-ui.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.alertmanager-ui.tls=true",
        "traefik.http.routers.alertmanager-ui.tls.certresolver=letsencrypt",
        "traefik.http.routers.alertmanager-ui.middlewares=sslheader",
        "traefik.http.services.alertmanager-ui.loadbalancer.server.port=9093",
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https",
      ]

      check {
        name     = "http port alive"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "alertmanager" {
      driver = "docker"

      resources {
        cpu    = "500"
        memory = "300"
      }

      config {
        image      = "prom/alertmanager"
        force_pull = true
        ports      = ["http"]
        args = [
          "--config.file=/local/alertmanager.yml",
          "--storage.path=/alloc/data",
        ]

        extra_hosts = [
          "host.docker.internal:host-gateway"
        ]
      }

      template {
        destination     = "local/alertmanager.yml"
        left_delimiter  = "{{{"
        right_delimiter = "}}}"
        data            = <<EOF
route:
  group_by: ["host"]
  group_wait: 15s
  group_interval: 5m
  repeat_interval: 2h
  receiver: "slack"

  # All the above attributes are inherited by all child routes and can
  # overwritten on each.
  routes:
    - receiver: "slack"
      group_wait: 15s
      repeat_interval: 1d
      continue: true

receivers:
{{{- with nomadVar "nomad/jobs/alertmanager" }}}
  - name: "slack"
    slack_configs:
      - api_url: '{{{ .slack_webhook_url }}}'
        send_resolved: true
        channel: 'alerts'
        title: "{{ range .Alerts }}{{ .Annotations.summary }}\n{{ end }}"
        text: |-
            <!channel>
            {{ range .Alerts }}
            *{{ index .Labels "alertname" }}* {{- if .Annotations.summary }}: *{{ .Annotations.summary }}* {{- end }}
            {{- if .Annotations.description }}
                _{{ .Annotations.description }}_
            {{- end }}
            {{- end }}
{{{- end }}}

EOF
      }
    }
  }
}
