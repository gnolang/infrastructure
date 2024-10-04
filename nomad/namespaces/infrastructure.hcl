name        = "infrastructure"
description = "Limited namespace for infrastructure purpose"

capabilities {
  enabled_task_drivers  = ["docker"]
  disabled_task_drivers = ["raw_exec"]
}

meta {
}
