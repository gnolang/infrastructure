name        = "monitoring"
description = "Limited namespace for monitoring purpose"

capabilities {
  enabled_task_drivers  = ["docker"]
  disabled_task_drivers = ["raw_exec"]
}

meta {
}
