job "redis" {
  group "cache" {
    count = 6

    network {
      port "db" {
        to = 6379
      }
    }

    service {
      name = "redis"
      port = "6379"
    }

    task "redis" {
      driver = "docker"

      config {
        image = "redis:latest"
        ports = ["db"]
      }

      resources {
        cpu    = 500
        memory = 256
      }
    }
  }
}
