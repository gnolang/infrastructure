job "vector" {
  type        = "system"
  namespace   = "monitoring"
  datacenters = ["*"]

  group "vector" {

    volume "docker-sock-ro" {
      type      = "host"
      source    = "docker-sock-ro"
      read_only = true
    }

    volume "journald-ro" {
      type      = "host"
      source    = "journald-ro"
      read_only = true
    }

    network {
      port "api" {
        to           = 8686
        host_network = "private"
      }

      port "metrics" {
        to           = 9598
        host_network = "private"
      }
    }

    service {
      name     = "vector-api"
      port     = "api"
      provider = "nomad"

      check {
        type     = "http"
        path     = "/health"
        interval = "10s"
        timeout  = "2s"
      }
    }

    service {
      name     = "vector-metrics"
      port     = "metrics"
      provider = "nomad"

      tags = [
        "metrics"
      ]
      check {
        type     = "http"
        path     = "/metrics"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "vector" {
      driver = "docker"

      config {
        image = "timberio/vector:0.36.0-alpine"
        args  = ["-c", "/local/vector.yaml"]
        ports = ["api", "metrics"]
        volumes = [
        ]
      }

      resources {
        cpu    = 300
        memory = 250
      }

      volume_mount {
        volume      = "docker-sock-ro"
        destination = "/var/run/docker.sock"
        read_only   = true
      }

      volume_mount {
        volume      = "journald-ro"
        destination = "/var/log/journal"
        read_only   = true
      }

      env {
        NOMAD_HOST = "${node.unique.name}"
      }

      template {
        data = yamlencode({
          api = {
            enabled = true
            address = "0.0.0.0:8686"
          }
          sources = {
            docker = {
              type = "docker_logs"
              exclude_containers = [
                "vector-",
                "loki-",
                "nomad_init_",
              ]
            }

            vector_metrics = {
              type                 = "internal_metrics"
              scrape_interval_secs = 10
            }
          }

          transforms = {
            parse_logs = {
              type   = "remap"
              inputs = ["docker"]
              source = <<EOF
                . = parse_logfmt!(.message)
              EOF

            }
          }

          sinks = {
            loki = {
              type        = "loki"
              inputs      = ["docker"] # ["docker", "apps_logs", "host_journald_logs"]
              endpoint    = "https://loki.infra.allinbits.vip"
              compression = "snappy"
              encoding = {
                codec = "json"
              }
              healthcheck = {
                enabled = false # TODO(albttx): set to true and check it
              }
              out_of_order_action = "drop"
              labels = {
                nomad_node = "$NOMAD_HOST"
                # nomad_dc = "{{ label.\"com.hashicorp.nomad.dc\" }}"
                nomad_job       = "{{ label.\"com.hashicorp.nomad.job_name\" }}"
                nomad_group     = "{{ label.\"com.hashicorp.nomad.task_group_name\" }}"
                nomad_task      = "{{ label.\"com.hashicorp.nomad.task_name\" }}"
                nomad_alloc     = "{{ label.\"com.hashicorp.nomad.alloc_id\" }}"
                nomad_namespace = "{{ label.\"com.hashicorp.nomad.namespace\" }}"
              }
              batch = {
                timeout_secs = 5
              }
            }

            prometheus-exporter = {
              type    = "prometheus_exporter"
              inputs  = ["vector_metrics"]
              address = "0.0.0.0:9598"
            }
          }
        })

        destination     = "local/vector.yaml"
        left_delimiter  = "[["
        right_delimiter = "]]"
      }

    }
  }
}
