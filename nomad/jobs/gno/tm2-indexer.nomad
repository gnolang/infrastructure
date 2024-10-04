job "tm2-indexer" {
  type = "service"

  datacenters = ["*"]
  region      = "eu-london"
  namespace   = "gno"

  group "test4" {
    count = 1

    task "tm2-indexer" {
      driver = "docker"

      resources {
        cpu    = 4000
        memory = 1200
      }

      config {
        image        = "ghcr.io/allinbits/infrastructure/tm2-indexer"
        force_pull   = true
        args         = ["--config=/local/config.toml"]

        auth {
          server_address = "ghcr.io"
          username       = "${DOCKER_USER}"
          password       = "${DOCKER_PASSWORD}"
        }
      }

      template {
        env         = true
        data        = <<EOF
{{ with nomadVar "nomad/jobs" }}
DOCKER_USER={{ .gnobot_docker_user }}
DOCKER_PASSWORD={{ .gnobot_docker_pass }}
{{ end }}
EOF
        destination = "local/docker-env.txt"
      }

      template {
        destination = "local/config.toml"
        data        = <<EOF
[rpc]
endpoint = "https://rpc.test4.gno.land"

{{- with nomadVar "nomad/jobs/tm2-indexer/test4" }}
[database]
endpoint = "{{ .psql_uri }}"
{{- end }}

[chain]
[chain.validators]
devx-val-1   = "g1mxguhd5zacar64txhfm0v7hhtph5wur5hx86vs"
devx-val-2   = "g1t9ctfa468hn6czff8kazw08crazehcxaqa2uaa"
core-val-1   = "g19v2h4pn6lrf8pwvhn8h0anek0cpt2tmhye4vkv"
core-val-2   = "g13us7swtc9hq550y9v4z6vcarak9vf8nqdvcqj4"
core-val-3   = "g1ectm6algkfw3qnjmjvx7hacmh358t36ggj5lqv"
core-val-4   = "g1tcxls3ylnrwrq95j33xpyuct4l370ra7jca4kj"
onbloc-val-1 = "g1gav33elude7prcdctpjekze7ft9l8qdjxqaj6d"

[scrapper]
batch_write = 300
goro_block_parser = 32

buffer_chan_blocks = 1000
buffer_chan_heights = 10000
EOF
      }
    }
  }
}
