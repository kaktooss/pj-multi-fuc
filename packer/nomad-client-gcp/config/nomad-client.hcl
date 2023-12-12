acl {
  enabled = false
}

client {
  enabled = true
}

plugin "docker" {
  config {
    allow_privileged = true
    allow_caps       = ["ALL"]
    extra_labels     = ["job_name", "job_id", "task_group_name", "task_name", "namespace", "node_name", "node_id"]
    volumes {
      enabled      = true
      selinuxlabel = "z"
    }
  }
}

plugin "podman" {
  volumes {
    enabled = true
  }
}

plugin "raw_exec" {
  config {
    enabled = true
  }
}

consul {
  address             = "dt-consul.codehound.cz:8500"
  server_service_name = "nomad-server"
  client_service_name = "nomad-client"
  auto_advertise      = true
  server_auto_join    = true
  client_auto_join    = true
}
