data_dir: "/var/lib/vector"

sources:
  docker_source:
    type: docker_logs

sinks:
  loki:
    type: loki
    tenant_id: nomad
    out_of_order_action: drop
    labels:
      type: nomad
      nomad_namespace: "{{ label.\"com.hashicorp.nomad.namespace\" }}"
      nomad_job: "{{ label.\"com.hashicorp.nomad.job_name\" }}"
      nomad_group: "{{ label.\"com.hashicorp.nomad.task_group_name\" }}"
      nomad_task: "{{ label.\"com.hashicorp.nomad.task_name\" }}"
      nomad_node: "{{ label.\"com.hashicorp.nomad.node_name\" }}"
      nomad_alloc: "{{ label.\"com.hashicorp.nomad.alloc_id\" }}"
      stream: "{{ stream }}"
    encoding:
      codec: text
    auth:
      strategy: basic
      user: nomad
      password: nomad
    inputs:
      - docker_source
    endpoint: http://loki.dt.codehound.cz
