job "meilisearch" {
  type        = "service"
  namespace   = "gno"
  datacenters = ["latitude_*"]

  constraint {
    attribute = "${node.unique.name}"
    operator  = "regexp"
    value     = "nt-.*"
  }

  group "meilisearch" {
    count = 1

    ephemeral_disk {
      size    = 2000
      sticky  = true
      migrate = true
    }

    network {
      port "http" {
        to           = 7700
        host_network = "private"
      }
    }

    service {
      name     = "meilisearch-web"
      port     = "http"
      provider = "nomad"

      tags = [
        "traefik.enable=true",

        "traefik.http.routers.meilisearch-http.rule=Host(`docs-search.gnoteam.com`)",
        "traefik.http.routers.meilisearch-http.entrypoints=web,websecure",
        "traefik.http.routers.meilisearch-http.tls=true",
        "traefik.http.routers.meilisearch-http.tls.certresolver=letsencrypt",
      ]
    }

    task "meilisearch" {
      driver = "docker"

      config {
        image = "getmeili/meilisearch:latest"
        force_pull = true
        tty = true
        ports    = ["http"]
      }

      env {
        MEILI_ENV           = "production"
        MEILI_NO_ANALYTICS  = true
        MEILI_LOG_LEVEL     = "info"
        MEILI_DB_PATH       = "/alloc/data/data.ms"
      }

      template {  
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOF
{{- with nomadVar "nomad/jobs/meilisearch" }}  
MEILI_MASTER_KEY="{{ .meili_master_key }}"
{{- end }}  
EOF  
      }
    }

  }
}
