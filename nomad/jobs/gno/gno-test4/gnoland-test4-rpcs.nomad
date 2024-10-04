# For this job to run, the policy `gno-test4.policy.hcl` need to be set.
# nomad acl policy apply -namespace gno -job gno-test4 gno-devnet-1 policies/gno-devnet-1.policy.hcl

job "gnoland-test4-rpc" {
  type        = "service"
  region      = "eu-london"
  namespace   = "gno"
  datacenters = ["*"]

  group "rpc" {
    count = 1

    network {
      port "p2p" {
        to           = 26656
        host_network = "private"
      }

      port "rpc" {
        to           = 26657
        host_network = "private"
      }
    }


    service {
      name     = "gno-test4-rpc"
      provider = "nomad"
      port     = "rpc"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gno-test4-rpc.rule=Host(`gno-devnet-rpc.infra.allinbits.vip`)",
        "traefik.http.routers.gno-test4-rpc.entrypoints=ts-web,ts-websecure",
        "traefik.http.routers.gno-test4-rpc.tls=true",
        "traefik.http.routers.gno-test4-rpc.tls.certresolver=letsencrypt",
        "traefik.http.routers.gno-test4-rpc.middlewares=sslheader",
        // "traefik.http.services.gno-test4-rpc.loadbalancer.server.port=3000",
        "traefik.http.middlewares.sslheader.headers.customrequestheaders.X-Forwarded-Proto=https",
      ]
    }

    task "gnoland" {
      driver = "docker"

      identity {
        file = true
        env  = true
      }

      config {
        image      = "ghcr.io/gnolang/gno/gnoland:master"
        force_pull = true
        entrypoint = ["/local/entrypoint.sh"]
        # entrypoint = [ "/bin/sh" ]
        tty      = true
        work_dir = "/gnoroot"
        ports    = ["p2p", "rpc"]
        volumes = [
          # "local/priv_validator_key.json"
        ]
      }

      env {
        CHAIN_ID      = "gnoland-test4"
        EXTERNAL_ADDR = "${NOMAD_HOST_ADDR_p2p}"

        TELEMETRY_EXPORTER_ENDPOINT = "https://prometheus.infra.allinbits.vip/api/v1/otlp/v1/metrics"
        CONSENSUS_TIMEOUT_COMMIT    = "1s"
      }

      template {
        destination = "local/env"
        env         = true
        change_mode = "noop"
        data        = <<EOF
          MONIKER=gnode-devnet-{{ env "NOMAD_ALLOC_INDEX" | parseInt | add 1 }}
        EOF
      }

      template {
        destination = "local/services.txt"
        change_mode = "noop"
        data        = <<EOF
# gno-test4-p2p
          {{- range nomadService "gno-test4-p2p" }}
            {{ .Address }}:{{ .Port }}
          {{ end }}

# gno-test4-0-p2p
          {{- range nomadService "gno-test4-0-p2p" }}
            {{ .Address }}:{{ .Port }}
          {{ end }}
        EOF
      }

      template {
        destination = "local/entrypoint.sh"
        change_mode = "noop"
        data        = file("./scripts/start.sh")
        perms       = "0744"
      }

      template {
        destination     = "local/genesis.json"
        data            = file("./gnoland-test4/genesis.json")
        left_delimiter  = "[[--"
        right_delimiter = "--]]"
      }

      # template {
      #   destination = "local/node/config/config.toml"
      #   data        = file(
      #     format("./scripts/node-%s/config/config.toml", convert("${NOMAD_ALLOC_INDEX}", number))
      #   )
      # }


      template {
        destination = "local/node_key.json"
        change_mode = "noop"
        data        = <<EOF
          {{ with nomadVar (printf "nomad/jobs/gno-test4/nodes/gnoland/%d" ( env "NOMAD_ALLOC_INDEX" | parseInt | add 1 ) ) }}
          {{ .node_key }}
          {{ end }}
        EOF
      }

      template {
        destination = "local/priv_validator_key.json"
        change_mode = "noop"
        data        = <<EOF
          {{ with nomadVar (printf "nomad/jobs/gno-test4/nodes/gnoland/%d" ( env "NOMAD_ALLOC_INDEX" | parseInt | add 1 ) ) }}
          {{ .priv_validator_key }}
          {{ end }}
        EOF
      }

      resources {
        cpu    = 8000
        memory = 6000
      }
    }
  }
}
