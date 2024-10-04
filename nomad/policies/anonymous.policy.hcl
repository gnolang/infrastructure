namespace "default" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "monitoring" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "infrastructure" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "atomone" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
}

namespace "gno" {
  policy       = "read"
  capabilities = ["list-jobs", "read-job"]
  variables {
    path "*" {
      capabilities = ["read"]
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

host_volume "*" {
  policy = "read"
}

