namespace "gno" {
  policy = "read"
  # this policy can write, read, or destroy any variable in any namespace
  variables {
    path "*" {
      capabilities = ["read"]
    }
  }
}
