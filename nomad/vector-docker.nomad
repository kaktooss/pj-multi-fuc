job "vector" {
  datacenters = ["dct", "gcp-eu", "aws-eu"]
  namespace   = "default"
  type        = "system"
  priority    = 99

  group "vector" {
    count = 1
    restart {
      attempts = 3
      interval = "10m"
      delay    = "30s"
      mode     = "fail"
    }

    task "vector" {
      driver = "docker"

      template {
        data        = file(abspath("./files/vector.yaml.tpl"))
        destination = "local/vector.yaml"
        change_mode = "restart"
        perms       = "666"

        # overriding the delimiters to [[ ]] to avoid conflicts with Vector's native templating, which also uses {{ }}
        left_delimiter  = "[["
        right_delimiter = "]]"
      }

      resources {
        memory = 150
      }

      config {
        image        = "timberio/vector:0.34.1-alpine"
        #image        = "timberio/vector:0.34.1-debian"
        args         = ["-c", "/local/vector.yaml"]
        network_mode = "host"
        privileged   = true
        mount {
          type     = "bind"
          target   = "/var/run/docker.sock"
          source   = "/var/run/docker.sock"
          readonly = false
        }
      }
      kill_timeout = "60s"
    }
  }
}
