
job "gno-alerters" {
  type = "service"

  datacenters = ["*"]
  region      = "eu-london"
  namespace   = "gno"

  group "test4" {
    count = 1

    task "gno-alerter" {
      driver = "docker"

      resources {
        cpu    = 300
        memory = 500
      }

      config {
        image        = "ghcr.io/allinbits/infrastructure/gno-alerter"
        args         = ["--config=/local/config.toml"]
        force_pull   = true

        auth {
          server_address = "ghcr.io"
          username       = "${DOCKER_USER}"
          password       = "${DOCKER_PASSWORD}"
        }
      }

      template {
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs/gno-alerters" }}
DOCKER_USER={{ .docker_user }}
DOCKER_PASSWORD={{ .docker_password }}
{{ end }}
EOF
        destination = "local/docker-env.txt"
      }

      template {
        destination = "local/config.toml"
        data        = <<EOF
[rpc]
endpoint = "https://rpc.test4.gno.land"

[alerts]
stalled_period = "25s"
consecutive_missed = [20, 100, 500]

{{- with nomadVar "nomad/jobs/gno-alerters" }}
[slack]
token      = "{{ .slack_token }}"
channel_id = "{{ .slack_channel_id }}"
{{- end }}
EOF
      }
    }
  }
}
