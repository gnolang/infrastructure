job "grafana" {
  type        = "service"
  namespace   = "monitoring"
  region      = "eu-london"
  datacenters = ["do_*"]

  group "grafana" {
    count = 1

    volume "csi-grafana" {
      type            = "csi"
      source          = "csi-monitoring-grafana"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to           = 3000
        host_network = "private"
      }
    }

    service {
      name     = "grafana"
      provider = "nomad"
      port     = "http"
      tags = [
        "metrics",
        "traefik.enable=true",
        "traefik.http.routers.grafana-ui.rule=Host(`grafana.infra.allinbits.vip`)",
        "traefik.http.routers.grafana-ui.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.grafana-ui.tls=true",
        "traefik.http.routers.grafana-ui.tls.certresolver=letsencrypt",
        "traefik.http.routers.grafana-ui.middlewares=sslheader",
        // "traefik.http.services.grafana-ui.loadbalancer.server.port=3000",
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https",
      ]

      check {
        name     = "http port alive"
        type     = "http"
        path     = "/api/health"
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
          "chown -R 472:472 /var/lib/grafana"
        ]
      }

      volume_mount {
        volume      = "csi-grafana"
        destination = "/var/lib/grafana"
        read_only   = false
      }
    }


    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana:11.1.2"
        ports = ["http"]
        volumes = [
        ]
      }

      volume_mount {
        volume      = "csi-grafana"
        destination = "/var/lib/grafana"
      }

      resources {
        cpu    = 2000
        memory = 4000
        # memory_max = 6000
      }

      env {
        GF_LOG_LEVEL                   = "ERROR"
        GF_LOG_MODE                    = "console"
        GF_ANALYTICS_REPORTING_ENABLED = "false"

        GF_AUTH_ANONYMOUS_ENABLED = true

        GF_SECURITY_DISABLE_GRAVATAR = "true"
        GF_USERS_ALLOW_SIGN_UP       = "false"
        GF_USERS_ALLOW_ORG_CREATE    = "false"
        // GF_PATHS_DATA         = "/alloc/data"
        GF_SERVER_ROOT_URL = "https://grafana.infra.allinbits.vip"
        # GF_PATHS_PROVISIONING = "/local/grafana/provisioning"
        GF_INSTALL_PLUGINS = "grafana-piechart-panel,marcusolsson-json-datasource"

        GF_AUTH_GOOGLE_ENABLED   = "true"
        GF_AUTH_GOOGLE_AUTH_URL  = "https://accounts.google.com/o/oauth2/v2/auth"
        GF_AUTH_GOOGLE_TOKEN_URL = "https://oauth2.googleapis.com/token"
        GF_ALLOWED_DOMAINS       = "https://grafana.infra.allinbits.vip" # Your company domain and every other domain you want to grant access to (for example your clients)
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/grafana/grafana/grafana" }}
GF_AUTH_GOOGLE_CLIENT_ID       = "{{ .gf_google_client_id }}"     # Client ID that we obtained when we created the credentials in GCP
GF_AUTH_GOOGLE_CLIENT_SECRET   = "{{ .gf_google_client_secret }}" # Client Secret that we obtained when we created the credentials in GCP
{{ end }}
EOF
      }
    }
  }
}
