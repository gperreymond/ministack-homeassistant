job "vector-homeassistant" {
  datacenters = ["europe-paris"]
  namespace   = "monitoring-system"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "vector-homeassistant" {
    count = 1
    task "vector-homeassistant" {
      driver = "docker"
      user   = "root"

      config {
        image      = "timberio/vector:${vector_docker_tag}"
        privileged = true
        volumes = [
          "/mnt/vector/homeassistant:/etc/vector/config",
        ]
        extra_hosts = [
          "homeassistant.internal:10.1.0.2",
          "prometheus.homeassistant.internal:10.1.0.2",
        ]
      }

      template {
        env         = true
        data        = <<-EOF
VECTOR_CONFIG_DIR=/etc/vector/config
EOF
        destination = "local/.env"
      }

      resources {
        cpu    = 125
        memory = 256
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}
