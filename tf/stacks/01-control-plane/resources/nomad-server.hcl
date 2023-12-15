data_dir             = "/opt/nomad/data"
datacenter           = "dc1"
disable_update_check = true

acl {
  enabled = false
}

telemetry {
  collection_interval        = "1s"
  disable_hostname           = true
  prometheus_metrics         = true
  publish_allocation_metrics = true
  publish_node_metrics       = true
}

server {
  enabled            = true
  bootstrap_expect   = 3
  node_gc_threshold  = "1m"
  rejoin_after_leave = false
}

consul {
  # The address to the Consul agent.
  address = "${consul_addr}"

  # The service name to register the server and client with Consul.
  server_service_name = "nomad-server"
  client_service_name = "nomad-client"

  # Enables automatically registering the services.
  #auto_advertise = true

  # Enabling the server and client to bootstrap using Consul.
  server_auto_join = true
  client_auto_join = true
}
