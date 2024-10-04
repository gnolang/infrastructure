namespace "default" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "gno" {
  policy       = "write"
  capabilities = [
    "list-jobs",
    "read-job",
    "list-jobs",
    "parse-job",
    "read-job",
    "submit-job",
    "dispatch-job",
    "read-logs",
    "read-fs",
    "alloc-exec",
    "alloc-lifecycle",
    "csi-write-volume",
    "csi-mount-volume",
    "list-scaling-policies",
    "read-scaling-policy",
    "read-job-scaling",
    "scale-job",
  ]

  variables {
    path "*" {
      capabilities = ["write", "read", "destroy", "list"]
    }
  }
}

agent {
  policy = "read"
}

operator {
  policy = "read"
}

quota {
  policy = "read"
}

node {
  policy = "read"
}

plugin {
  policy = "read"
}

host_volume "*" {
  policy = "read"
}

