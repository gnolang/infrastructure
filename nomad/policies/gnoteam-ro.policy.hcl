namespace "gno" {
  policy       = "read"
  capabilities = [
    "list-jobs",
    "read-job",
    "read-logs",
    "read-fs",
  ]
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

