job "loki" {
  type        = "service"
  namespace   = "monitoring"
  datacenters = ["do_*"]

  group "loki" {
    count = 1

    volume "csi-loki" {
      type            = "csi"
      source          = "csi-monitoring-loki"
      read_only       = false
      access_mode     = "single-node-writer"
      attachment_mode = "file-system"
    }

    network {
      port "http" {
        to           = 3100
        host_network = "private"
      }

      port "grpc" {
        to           = 9096
        host_network = "private"
      }
    }

    service {
      name     = "loki-http"
      port     = "http"
      provider = "nomad"

      tags = [
        "metrics",
        "traefik.enable=true",
        "traefik.http.routers.loki-http.rule=Host(`loki.infra.allinbits.vip`)",
        "traefik.http.routers.loki-http.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.loki-http.tls=true",
        "traefik.http.routers.loki-http.tls.certresolver=letsencrypt",
        "traefik.http.routers.loki-http.middlewares=sslheader",
      ]
    }

    service {
      name     = "loki-grpc"
      port     = "grpc"
      provider = "nomad"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.loki-grpc-plaintext.rule=Host(`loki-grpc.infra.allinbits.vip`)",
        "traefik.http.routers.loki-grpc-plaintext.entrypoints=ts-grpc",

        "traefik.http.routers.loki-grpc.rule=Host(`loki-grpc.infra.allinbits.vip`)",
        "traefik.http.routers.loki-grpc.entrypoints=ts-grpc",
        "traefik.http.routers.loki-grpc.tls=true",
        "traefik.http.routers.loki-grpc.tls.certresolver=letsencrypt",
        "traefik.http.services.loki-grpc.loadbalancer.server.scheme=h2c",
        "traefik.http.services.loki-grpc.loadbalancer.server.port=${NOMAD_HOST_PORT_grpc}",
      ]
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
          "chown -R 10001:10001 /data"
        ]
      }

      volume_mount {
        volume      = "csi-loki"
        destination = "/data"
        read_only   = false
      }
    }


    task "loki" {
      driver = "docker"

      config {
        image = "grafana/loki:2.9.8"
        args = [
          "-config.file=/local/loki.yml",
        ]
        ports = ["http", "grpc"]
      }

      volume_mount {
        volume      = "csi-loki"
        destination = "/data"
        read_only   = false
      }

      template {
        data        = file("./jobs/monitoring/loki.yml")
        destination = "local/loki.yml"
        perms       = "0644"
      }

      resources {
        cpu    = 1000
        memory = 5000
      }
    }
  }
}
