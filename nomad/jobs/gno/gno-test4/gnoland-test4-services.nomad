job "gnoland-test4-services" {
  type        = "service"
  region      = "eu-london"
  namespace   = "gno"
  datacenters = ["latitude_*"]

  group "gnoweb" {
    count = 1

    network {
      port "http" {
        to           = 8888
        host_network = "private"
      }
    }

    service {
      name     = "gno-test4-gnoweb"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gno-test4-gnoweb.rule=Host(`test4.gno.land`)",
        "traefik.http.routers.gno-test4-gnoweb.entrypoints=web,websecure",
        "traefik.http.routers.gno-test4-gnoweb.tls=true",
        "traefik.http.routers.gno-test4-gnoweb.tls.certresolver=letsencrypt-tls",
      ]
    }

    task "gnoweb" {
      driver = "docker"

      resources {
        cpu    = 2000
        memory = 2000
      }

      config {
        image      = "ghcr.io/gnolang/gno/gnoweb:master"
        force_pull = true
        ports      = ["http"]

        args = [
          "--bind=0.0.0.0:8888",
          "--remote=https://rpc.test4.gno.land:443",
          "--faucet-url=https://faucet-api.test4.gno.land",
          "--with-analytics",
          "--captcha-site=${CAPTCHA_SITE_KEY}",
          "--help-chainid=test4",
          "--help-remote=https://rpc.test4.gno.land:443",
        ]
      }


      template {
        destination = "local/env"
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/gnoland-test4-services/gnoweb" }}
    CAPTCHA_SITE_KEY={{ .captcha_site_key }}
{{ end }}
        EOF
      }


    }
  }


  group "gnofaucet" {
    count = 1

    network {
      port "http" {
        to           = "5050"
        host_network = "private"
      }
    }

    service {
      name     = "gno-test4-gnofaucet"
      provider = "nomad"
      port     = "http"
      tags = [
        "traefik.enable=true",
        "traefik.http.routers.gno-test4-gnofaucet.rule=Host(`faucet-api.test4.gno.land`)",
        "traefik.http.routers.gno-test4-gnofaucet.entrypoints=web,websecure",
        "traefik.http.routers.gno-test4-gnofaucet.tls=true",
        "traefik.http.routers.gno-test4-gnofaucet.tls.certresolver=letsencrypt-tls",
      ]
    }

    task "gnofaucet" {
      driver = "docker"

      resources {
        cpu    = 1000
        memory = 1000
      }

      config {
        image      = "ghcr.io/gnolang/gno/gnofaucet-slim"
        force_pull = true
        ports      = ["http"]

        args = [
          "serve",
          "--listen-address=0.0.0.0:5050",
          "--chain-id=test4",
          "--is-behind-proxy=true",
          "--mnemonic=${FAUCET_MNEMONIC}",
          "--num-accounts=10",
          "--remote=https://rpc.test4.gno.land:443",
          "--captcha-secret=${CAPTCHA_SECRET_KEY}",
        ]
      }

      template {
        destination = "local/env"
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/gnoland-test4-services/gnofaucet" }}
    FAUCET_MNEMONIC={{ .faucet_mnemonic }}
    CAPTCHA_SECRET_KEY={{ .captcha_secret_key }}
{{ end }}
        EOF
      }

    }
  }
}
