namespace "default" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "monitoring" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
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
