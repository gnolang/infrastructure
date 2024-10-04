job "traefik" {
  type        = "service"
  datacenters = ["*"]
  namespace   = "infrastructure"

  constraint {
    attribute = "${meta.loadbalancer}"
    value     = "true"
  }

  group "traefik" {
    count = 2

    constraint {
      operator = "distinct_hosts"
      value    = "true"
    }

    network {
      port "http" {
        static       = 80
        host_network = "public"
      }
      port "https" {
        static       = 443
        host_network = "public"
      }

      port "ts-http" {
        static       = 80
        host_network = "private"
      }
      port "ts-https" {
        static       = 443
        host_network = "private"
      }

      port "p2p" {
        static       = 26656
        host_network = "public"
      }
      port "ts-p2p" {
        static       = 26656
        host_network = "private"
      }


      port "rpc" {
        static       = 26657
        host_network = "public"
      }
      port "ts-rpc" {
        static       = 26657
        host_network = "private"
      }


      port "grpc" {
        static       = 9090
        host_network = "public"
      }
      port "ts-grpc" {
        static       = 9090
        host_network = "private"
      }

      port "metrics" {
        static       = 8082
        host_network = "private"
      }
    }

    service {
      name     = "traefik-https"
      provider = "consul"
      tags = [
        "traefik.http.routers.traefik-secure.tls.domains[0].main=allinbits.vip",
        "traefik.http.routers.traefik-secure.tls.domains[0].sans=*.allinbits.vip",
        "traefik.http.routers.traefik-secure.tls.domains[1].main=infra.allinbits.vip",
        "traefik.http.routers.traefik-secure.tls.domains[1].sans=*.infra.allinbits.vip",
      ]
    }

    service {
      name     = "traefik-console"
      provider = "consul"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik-dashboard.rule=Host(`traefik.infra.allinbits.vip`)",
        "traefik.http.routers.traefik-dashboard.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.traefik-dashboard.service=api@internal",
        "traefik.http.routers.traefik-dashboard.tls=true",
        "traefik.http.routers.traefik-dashboard.tls.certresolver=letsencrypt",
      ]
    }

    service {
      name     = "nomad-dashboard"
      provider = "consul"
      tags = [
        "traefik.enable=true",
        "traefik.http.services.nomad-dashboard.loadbalancer.server.port=4646",
        "traefik.http.routers.nomad-dashboard.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.nomad-dashboard.rule=Host(`nomad.infra.allinbits.vip`)",
        "traefik.http.routers.nomad-dashboard.service=nomad-dashboard",
        "traefik.http.routers.nomad-dashboard.tls=true",
        "traefik.http.routers.nomad-dashboard.tls.certresolver=letsencrypt",
      ]
    }

    service {
      name     = "consul-dashboard"
      provider = "consul"
      tags = [
        "traefik.enable=true",
        "traefik.http.services.consul-dashboard.loadbalancer.server.port=8500",
        "traefik.http.routers.consul-dashboard.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.consul-dashboard.rule=Host(`consul.infra.allinbits.vip`)",
        "traefik.http.routers.consul-dashboard.service=consul-dashboard",
        "traefik.http.routers.consul-dashboard.tls=true",
        "traefik.http.routers.consul-dashboard.tls.certresolver=letsencrypt",
      ]
    }

    service {
      name     = "traefik-metrics"
      provider = "consul"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.traefik-prometheus.rule=Path(`/metrics`)",
        "traefik.http.routers.traefik-prometheus.entrypoints=metrics",
        "traefik.http.routers.traefik-prometheus.service=prometheus@internal",
        # "traefik.http.routers.traefik-prometheus.tls=true",
        # "traefik.http.routers.traefik-prometheus.tls.certresolver=letsencrypt",
      ]
    }


    task "dl_plugins" {
      driver = "docker"

      lifecycle {
        hook    = "prestart"
        sidecar = false
      }

      config {
        image   = "alpine/git"
        tty     = true

        entrypoint = [
            "/bin/sh",
            "${NOMAD_TASK_DIR}/entrypoint.sh"
        ]
      }

      template {
        destination = "${NOMAD_TASK_DIR}/entrypoint.sh"
        data        = <<EOF
#!/bin/sh

PLUGINS_DIR="${NOMAD_ALLOC_DIR}/plugins-local"

git clone https://github.com/albttx/traefik-plugin-sec-hasura ${PLUGINS_DIR}/src/github.com/albttx/traefik-plugin-sec-hasura
EOF
      }
    }

    task "server" {
      driver = "docker"

      resources {
        cpu        = 6000
        memory     = 4000
        memory_max = 6000
      }

      config {
        image        = "traefik:v2.11.0"
        work_dir     = "${NOMAD_ALLOC_DIR}"
        ports        = ["http", "https", "ts-http", "ts-https", "p2p", "ts-p2p", "rpc", "ts-rpc", "grpc", "ts-grpc", "metrics"]
        network_mode = "host"
        mounts = [
           {
             type     = "volume"
             target   = "/letsencrypt"
             source   = "letsencrypt"
             readonly = false
           }
         ]

        args = [
          "--log.level=INFO",
          "--api.dashboard=true",
          "--entrypoints.web.address=${NOMAD_ADDR_http}",
          "--entrypoints.websecure.address=${NOMAD_ADDR_https}",
          "--entrypoints.ts-web.address=${NOMAD_ADDR_ts_http}",
          "--entrypoints.ts-websecure.address=${NOMAD_ADDR_ts_https}",

          "--entrypoints.p2p.address=${NOMAD_ADDR_p2p}",
          "--entrypoints.ts-p2p.address=${NOMAD_ADDR_ts_p2p}",

          "--entrypoints.grpc.address=${NOMAD_ADDR_grpc}",
          "--entrypoints.ts-grpc.address=${NOMAD_ADDR_ts_grpc}",


          "--entrypoints.rpc.address=${NOMAD_ADDR_rpc}",
          "--entrypoints.ts-rpc.address=${NOMAD_ADDR_ts_rpc}",

          "--entrypoints.web.http.redirections.entryPoint.to=websecure",
          "--entrypoints.web.http.redirections.entryPoint.scheme=https",

          "--entrypoints.metrics.address=${NOMAD_ADDR_metrics}",

          "--metrics.prometheus=true",
          "--metrics.prometheus.addEntryPointsLabels=true",
          "--metrics.prometheus.addrouterslabels=true",
          "--metrics.prometheus.addServicesLabels=true",
          "--metrics.prometheus.manualrouting=true",
          "--metrics.prometheus.entrypoint=metrics",

          "--providers.nomad=true",
          # "--providers.nomad.endpoint.address=http://host.docker.internal:4646",
          "--providers.nomad.endpoint.address=http://${NOMAD_IP_ts_https}:4646",
          "--providers.nomad.endpoint.token=${NOMAD_TOKEN}",
          "--providers.nomad.namespaces=default,infrastructure,monitoring,gno,atomone",

          // "--providers.consul.endpoints=http://host.docker.internal:8500",
          // "--providers.consul.rootkey=traefik",

          "--providers.consulcatalog.endpoint.address=http://${NOMAD_IP_ts_https}:8500",
          // TODO
          // https://doc.traefik.io/traefik/providers/consul-catalog/#constraints
          "--providers.consulcatalog.exposedByDefault=false",
          "--providers.consulcatalog.prefix=traefik",
          "--providers.consulcatalog.defaultrule=Host(`{{ .Name }}.infra.allinbits.vip`)",

          "--certificatesresolvers.letsencrypt-tls.acme.email=dev@allinbits.com",
          "--certificatesresolvers.letsencrypt-tls.acme.tlschallenge=true",
          "--certificatesresolvers.letsencrypt-tls.acme.storage=/letsencrypt/acme-tls.json",


          "--certificatesresolvers.letsencrypt.acme.email=dev@allinbits.com",
          # TODO: see for storing this in consul
          "--certificatesresolvers.letsencrypt.acme.storage=/letsencrypt/acme.json",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge=true",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.delaybeforecheck=10",
          "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,1.0.0.1:53",
          // "!IMPORTANT - COMMENT OUT THE FOLLOWING LINE IN PRODUCTION!",
          // "--certificatesresolvers.letsencrypt.acme.caserver=https://acme-staging-v02.api.letsencrypt.org/directory",

          // "--certificatesresolvers.tailscale.tailscale=true"

          "--experimental.plugins.traefik-plugin-disable-graphql-introspection.modulename=github.com/hongbo-miao/traefik-plugin-disable-graphql-introspection",
          "--experimental.plugins.traefik-plugin-disable-graphql-introspection.version=v0.3.0",

          "--experimental.localplugins.hasura-sec.moduleName=github.com/albttx/traefik-plugin-sec-hasura",
        ]
        extra_hosts = ["host.docker.internal:host-gateway"]
      }

      template {
        destination = "${NOMAD_SECRETS_DIR}/env.txt"
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/traefik/traefik" }}
CLOUDFLARE_DNS_API_TOKEN = "{{ .CLOUDFLARE_DNS_API_TOKEN }}"
NOMAD_TOKEN = "{{ .NOMAD_TOKEN }}"
{{ end }}
EOF
      }
    }
  }
}
