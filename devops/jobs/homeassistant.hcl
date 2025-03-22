job "homeassistant" {
  datacenters = ["europe-paris"]
  namespace   = "homeassistant-system"
  type        = "service"

  constraint {
    attribute = "$${attr.unique.hostname}"
    value     = "europe-paris-${destination}"
  }

  group "homeassistant" {
    count = 1

    network {
      mode = "host"
      port "homeassistant-http" {
        static = 8123
      }
    }

    task "homeassistant" {
      driver = "docker"
      user   = "root"

      config {
        image        = "homeassistant/home-assistant:${homeassistant_docker_tag}"
        privileged   = true
        network_mode = "host"
        ports        = ["homeassistant-http"]
        volumes = [
          "/mnt/homeassistant_config_data:/config",
        ]
        extra_hosts = [
          "rds-postgres.homeassistant.internal:10.1.0.2",
        ]
      }

      template {
        env         = true
        data        = <<-EOF
TZ="Europe/Paris"
EOF
        destination = "secrets/.env"
      }

      resources {
        cpu    = 500
        memory = 512
      }

      service {
        provider = "nomad"
        name     = "homeassistant-http"
        port     = "homeassistant-http"
        check {
          type     = "http"
          path     = "/"
          interval = "10s"
          timeout  = "2s"
        }
        tags = [
          "traefik.enable=true",
          "traefik.http.routers.homeassistant.rule=Host(`homeassistant.internal`)",
          "traefik.http.routers.homeassistant.entrypoints=web",
          "traefik.http.services.homeassistant.loadbalancer.passhostheader=true",
        ]
      }

      logs {
        max_files     = 1
        max_file_size = 5
      }
    }
  }
}