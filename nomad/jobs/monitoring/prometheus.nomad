job "prometheus" {
  type = "service"

  datacenters = ["do_*"]
  region      = "eu-london"
  namespace   = "monitoring"

  constraint {
    attribute = "${meta.monitoring}"
    value     = "true"
  }

  group "monitoring" {
    count = 1

    volume "csi-prometheus" {
      type            = "csi"
      source          = "csi-monitoring-prometheus"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    restart {
      attempts = 2
      interval = "30m"
      delay    = "15s"
      mode     = "fail"
    }

    network {
      port "prometheus_ui" {
        to           = 9090
        host_network = "private"
      }
    }

    service {
      name     = "prometheus"
      provider = "nomad"
      port     = "prometheus_ui"
      tags = [
        "metrics",
        "traefik.enable=true",
        "traefik.http.routers.prometheus-ui.rule=Host(`prometheus.infra.allinbits.vip`)",
        "traefik.http.routers.prometheus-ui.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.prometheus-ui.tls=true",
        "traefik.http.routers.prometheus-ui.tls.certresolver=letsencrypt",
        "traefik.http.routers.prometheus-ui.middlewares=sslheader",
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https",

        "traefik.http.routers.prometheus-api.rule=PathPrefix(`/prometheus`)",
        "traefik.http.routers.prometheus-api.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.prometheus-api.tls=true",
        "traefik.http.routers.prometheus-api.tls.certresolver=letsencrypt",
        "traefik.http.middlewares.prom-api-stripprefix.stripprefix.prefixes=/prometheus"

      ]

      check {
        name     = "prometheus_ui port alive"
        type     = "http"
        path     = "/-/healthy"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "storage_init" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image   = "alpine:latest"
        command = "/bin/sh"
        args = [
          "-c",
          "chown -R 65534:65534 /prometheus"
        ]
      }

      volume_mount {
        volume      = "csi-prometheus"
        destination = "/prometheus"
        read_only   = false
      }
    }

    task "prometheus" {
      driver = "docker"

      config {
        image      = "prom/prometheus:v2.52.0"
        force_pull = true
        ports      = ["prometheus_ui"]

        args = [
          "--config.file=/etc/prometheus/prometheus.yml",
          "--storage.tsdb.path=/prometheus",

          "--web.listen-address=0.0.0.0:9090",
          "--web.route-prefix=/",
          "--web.external-url=https://prometheus.infra.allinbits.vip",
          "--web.console.libraries=/usr/share/prometheus/console_libraries",
          "--web.console.templates=/usr/share/prometheus/consoles",

          "--web.enable-remote-write-receiver",
          "--enable-feature=otlp-write-receiver",
        ]

        volumes = [
          "local/prometheus.yml:/etc/prometheus/prometheus.yml",
          "local/alerts:/etc/prometheus/alerts",
        ]

        extra_hosts = [
          "host.docker.internal:host-gateway"
        ]
      }

      volume_mount {
        volume      = "csi-prometheus"
        destination = "/prometheus"
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/prometheus" }}
NOMAD_TOKEN = "{{ .NOMAD_TOKEN }}"
{{ end }}
EOF
      }

      template {
        destination     = "local/alerts/rules_nodeexporter.yml"
        data            = file("./jobs/monitoring/alerts_rules_nodeexporter.yml")
        left_delimiter  = "{%"
        right_delimiter = "%}"
      }

      template {
        destination     = "local/alerts/rules_prometheus.yml"
        data            = file("./jobs/monitoring/alerts_rules_prometheus.yml")
        left_delimiter  = "{%"
        right_delimiter = "%}"
      }

      template {
        destination = "local/prometheus.yml"
        data        = file("./jobs/monitoring/prometheus.yml")
      }

      resources {
        cpu    = 1000
        memory = 3000
      }
    }
  }
}
