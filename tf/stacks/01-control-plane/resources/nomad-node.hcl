bind_addr = \"$${POD_IP}\"
advertise {
  http = \"${nomad_lb}:4646\"
  rpc = \"${nomad_lb}:4647\"
  serf =\"$${POD_NAME}-int.nomad.svc.cluster.local:4648\"
}